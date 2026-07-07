{
    Loop optimization

    Copyright (c) 2005 by Florian Klaempfl

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

 ****************************************************************************
}
unit optloop;

{$i fpcdefs.inc}

{ $define DEBUG_OPTSTRENGTH}
{ $define DEBUG_OPTFORLOOP}

  interface

    uses
      node;

    function unroll_loop(node : tnode) : tnode;
    function OptimizeInductionVariables(node : tnode) : boolean;
    function optimize_record_writes(var n: tnode): boolean;
    function OptimizeForLoop(var node : tnode) : boolean;
    function OptimizeLICM(node : tnode) : boolean;
    function OptimizeLoopUnswitch(node : tnode) : boolean;
    function OptimizeBitIdiom(node : tnode) : boolean;

  implementation

    uses
      cclasses,cutils,compinnr,cdynset,
      globtype,globals,constexp,
{$ifdef i386}
      cpuinfo,
{$endif i386}
      verbose,
      symbase,symconst,symdef,symsym,symtype,
      defutil,
      nutils,
      nadd,nbas,nflw,ncon,ninl,ncal,nld,nmem,ncnv,
      ncgmem,
      pass_1,
      optbase,optutils,
      procinfo;

    function number_unrolls(node : tnode) : cardinal;
      var
        nodeCount : cardinal;
      begin
        { calculate how often a loop shall be unrolled.

          The term (60*ord(node_count_weighted(node)<15)) is used to get small loops  unrolled more often as
          the counter management takes more time in this case. }
{$ifdef i386}
        { multiply by 2 for CPUs with a long pipeline }
        if current_settings.optimizecputype in [cpu_Pentium4] then
          begin
            { See the common branch below for an explanation. }
            nodeCount:=node_count_weighted(node,41);
            number_unrolls:=round((60+(60*ord(nodeCount<15)))/max(nodeCount,1))
          end
        else
{$endif i386}
          begin
            { If nodeCount >= 15, numerator will be 30,
              and the largest number (starting from 15) that makes sense as its denominator
              (the smallest number that gives number_unrolls = 1) is 21 = trunc(30/1.5+1),
              so there's no point in counting for more than 21 nodes.
              "Long pipeline" variant above is the same with numerator=60 and max denominator = 41. }
            nodeCount:=node_count_weighted(node,21);
            number_unrolls:=round((30+(60*ord(nodeCount<15)))/max(nodeCount,1));
          end;

        if number_unrolls=0 then
          number_unrolls:=1;
      end;

    type
      treplaceinfo = record
        node : tnode;
        value : Tconstexprint;
      end;
      preplaceinfo = ^treplaceinfo;

    function checkcontrollflowstatements(var n:tnode; arg: pointer): foreachnoderesult;
      begin
        if n.nodetype in [breakn,continuen,goton,labeln,exitn,raisen] then
          result:=fen_norecurse_true
        else
          result:=fen_false;
      end;


    function replaceloadnodes(var n: tnode; arg: pointer): foreachnoderesult;
      begin
        if n.isequal(preplaceinfo(arg)^.node) then
          begin
            if n.flags*[nf_modify,nf_write,nf_address_taken]<>[] then
              internalerror(2012090402);
            n.free;
            n:=cordconstnode.create(preplaceinfo(arg)^.value,preplaceinfo(arg)^.node.resultdef,false);
            do_firstpass(n);
          end;
        result:=fen_false;
      end;


    function unroll_loop(node : tnode) : tnode;
      var
        unrolls,i : cardinal;
        counts : qword;
        unrollstatement,newforstatement : tstatementnode;
        unrollblock : tblocknode;
        getridoffor : boolean;
        replaceinfo : treplaceinfo;
        hascontrollflowstatements : boolean;
      begin
        result:=nil;
        if (cs_opt_size in current_settings.optimizerswitches) then
          exit;
        if ErrorCount<>0 then
          exit;
        if not(node.nodetype in [forn]) then
          exit;
        unrolls:=number_unrolls(tfornode(node).t2);
        if (unrolls>1) and
          ((tfornode(node).left.nodetype<>loadn) or
           { the address of the counter variable might be taken if it is passed by constref to a
             subroutine, so really check if it is not taken }
           ((tfornode(node).left.nodetype=loadn) and (tloadnode(tfornode(node).left).symtableentry is tabstractvarsym) and
            not(tabstractvarsym(tloadnode(tfornode(node).left).symtableentry).addr_taken) and
            not(tabstractvarsym(tloadnode(tfornode(node).left).symtableentry).different_scope))
           ) then
          begin
            { number of executions known? }
            if (tfornode(node).right.nodetype=ordconstn) and (tfornode(node).t1.nodetype=ordconstn) then
              begin
                if lnf_backward in tfornode(node).loopflags then
                  counts:=tordconstnode(tfornode(node).right).value-tordconstnode(tfornode(node).t1).value+1
                else
                  counts:=tordconstnode(tfornode(node).t1).value-tordconstnode(tfornode(node).right).value+1;

                hascontrollflowstatements:=foreachnodestatic(tfornode(node).t2,@checkcontrollflowstatements,nil);

                { don't unroll more than we need,

                  multiply unroll by two here because we can get rid
                  of the counter variable completely and replace it by a constant
                  if unrolls=counts }
                if unrolls*2>=counts then
                  unrolls:=counts;

                { create block statement }
                unrollblock:=internalstatements(unrollstatement);

                { can we get rid completly of the for ? }
                getridoffor:=(unrolls=counts) and not(hascontrollflowstatements) and
                  { TP/Macpas allows assignments to the for-variables, so we cannot get rid of the for }
                  ([m_tp7,m_mac]*current_settings.modeswitches=[]);

                if getridoffor then
                  begin
                    replaceinfo.node:=tfornode(node).left;
                    replaceinfo.value:=tordconstnode(tfornode(node).right).value;
                  end
                else
                  { we consider currently unrolling not beneficial, if we cannot get rid of the for completely, this
                    might change if a more sophisticated heuristics is used (FK) }
                  exit;

                { let's unroll (and rock of course) }
                for i:=1 to unrolls do
                  begin
                    { create and insert copy of the statement block }
                    addstatement(unrollstatement,tfornode(node).t2.getcopy);

                    { set and insert entry label? }
                    if (counts mod unrolls<>0) and
                      ((counts mod unrolls)=unrolls-i) then
                      begin
                        tfornode(node).entrylabel:=clabelnode.create(cnothingnode.create,clabelsym.create('$optunrol'));
                        addstatement(unrollstatement,tfornode(node).entrylabel);
                      end;

                    if getridoffor then
                      begin
                        foreachnodestatic(tnode(unrollstatement),@replaceloadnodes,@replaceinfo);
                        if lnf_backward in tfornode(node).loopflags then
                          replaceinfo.value:=replaceinfo.value-1
                        else
                          replaceinfo.value:=replaceinfo.value+1;
                      end
                    else
                      begin
                        { for itself increases at the last iteration }
                        if i<unrolls then
                          begin
                            { insert incr/decrementation of counter var }
                            if lnf_backward in tfornode(node).loopflags then
                              addstatement(unrollstatement,
                                geninlinenode(in_dec_x,false,ccallparanode.create(tfornode(node).left.getcopy,nil)))
                            else
                              addstatement(unrollstatement,
                                geninlinenode(in_inc_x,false,ccallparanode.create(tfornode(node).left.getcopy,nil)));
                          end;
                       end;
                  end;
                { can we get rid of the for statement? }
                if getridoffor then
                  begin
                    { create block statement }
                    result:=internalstatements(newforstatement);
                    addstatement(newforstatement,unrollblock);
                    doinlinesimplify(result);
                  end;
              end
            else
              begin
                { unrolling is a little bit more tricky if we don't know the
                  loop count at compile time, but the solution is to use a jump table
                  which is indexed by "loop count mod unrolls" at run time and which
                  jumps then at the appropriate place inside the loop. Because
                  a module division is expensive, we can use only unroll counts dividable
                  by 2 }
                case unrolls of
                  1..2:
                    ;
                  3:
                    unrolls:=2;
                  4..7:
                    unrolls:=4;
                  { unrolls>4 already make no sense imo, but who knows (FK) }
                  8..15:
                    unrolls:=8;
                  16..31:
                    unrolls:=16;
                  32..63:
                    unrolls:=32;
                  64..$7fff:
                    unrolls:=64;
                  else
                    exit;
                end;
                { we don't handle this yet }
                exit;
              end;
            if not(assigned(result)) then
              begin
                tfornode(node).t2.free;
                tfornode(node).t2:=unrollblock;
              end;
          end;
      end;


    function checkcontinue(var n:tnode; arg: pointer): foreachnoderesult;
      begin
        if n.nodetype=continuen then
          result:=fen_norecurse_true
        else
          result:=fen_false;
      end;


    function is_loop_invariant(loop : tnode;expr : tnode) : boolean;
      begin
        result:=is_constnode(expr);
        case expr.nodetype of
          loadn:
            begin
              if (pi_dfaavailable in current_procinfo.flags) and
                assigned(loop.optinfo) and
                assigned(expr.optinfo) and
                not(expr.isequal(tfornode(loop).left)) then
                { no aliasing? }
                result:=(([nf_write,nf_modify]*expr.flags)=[]) and not(tabstractvarsym(tloadnode(expr).symtableentry).addr_taken) and
                { no definition in the loop? }
                  not(DynSetIn(tfornode(loop).t2.optinfo^.defsum,expr.optinfo^.index));
            end;
          vecn:
            begin
              result:=((tvecnode(expr).left.nodetype=loadn) or is_loop_invariant(loop,tvecnode(expr).left)) and
                is_loop_invariant(loop,tvecnode(expr).right);
            end;
          typeconvn:
            result:=is_loop_invariant(loop,ttypeconvnode(expr).left);
          addn,subn:
            result:=is_loop_invariant(loop,taddnode(expr).left) and is_loop_invariant(loop,taddnode(expr).right);
          else
            ;
        end;
      end;


    type
      toptimizeinductionvariablescontext = object
        currforloop : tfornode;
        initcode,
        calccode,
        deletecode : tblocknode;
        initcodestatements,
        calccodestatements,
        deletecodestatements: tstatementnode;
        ninductions : sizeint;
        inductions : array of record
          temp : ttempcreatenode;
          expr : tnode;
        end;
        changedforloop,
        containsnestedforloop,
        docalcatend : boolean;
        function findpreviousstrengthreduction(var n: tnode): boolean;
        procedure addinduction(temp : ttempcreatenode; expr : tnode);
        function dostrengthreductiontest(var n: tnode): foreachnoderesult;
        procedure optimizeinductionvariablessingleforloop(var n: tnode);
      end;


    function toptimizeinductionvariablescontext.findpreviousstrengthreduction(var n: tnode): boolean;
      var
        i : longint;
        hp : tnode;
      begin
        result:=false;
        for i:=0 to ninductions-1 do
          begin
            { do we already maintain one expression? }
            if inductions[i].expr.isequal(n) then
              begin
                case n.nodetype of
                  muln:
                    hp:=ctemprefnode.create(inductions[i].temp);
                  vecn:
                    hp:=ctypeconvnode.create_internal(cderefnode.create(ctemprefnode.create(inductions[i].temp)),n.resultdef);
                  else
                    internalerror(200809211);
                end;
                n.free;
                n:=hp;
                exit(true);
              end;
          end;
      end;


    procedure toptimizeinductionvariablescontext.addinduction(temp : ttempcreatenode; expr : tnode);
      begin
        if not assigned(initcode) then
          begin
            initcode:=internalstatements(initcodestatements);
            calccode:=internalstatements(calccodestatements);
            deletecode:=internalstatements(deletecodestatements);
            docalcatend:=not(assigned(currforloop.entrylabel)) and
              not(foreachnodestatic(currforloop.t2,@checkcontinue,nil));
          end;
        if ninductions>=length(inductions) then
          SetLength(inductions,4+ninductions+ninductions shr 1);
        inductions[ninductions].temp:=temp;
        inductions[ninductions].expr:=expr;
        inc(ninductions);
      end;


    { checks if the strength of n can be reduced, currforloop is the tforloop being considered }
    function toptimizeinductionvariablescontext.dostrengthreductiontest(var n: tnode): foreachnoderesult;
      var
        tempnode,startvaltemp : ttempcreatenode;
        dummy : longint;
        nn : tnode;
        nt : tnodetype;
        nflags : tnodeflags;
      begin
        result:=fen_false;
        nflags:=n.flags;
        case n.nodetype of
          forn:
            { inform for loop search routine, that it needs to search more deeply }
            containsnestedforloop:=true;
          muln:
            begin
              if (taddnode(n).right.nodetype=loadn) and
                taddnode(n).right.isequal(currforloop.left) and
                { plain read of the loop variable? }
                not(nf_write in taddnode(n).right.flags) and
                not(nf_modify in taddnode(n).right.flags) and
                is_loop_invariant(currforloop,taddnode(n).left) then
                taddnode(n).swapleftright;

              if (taddnode(n).left.nodetype=loadn) and
                taddnode(n).left.isequal(currforloop.left) and
                { plain read of the loop variable? }
                not(nf_write in taddnode(n).left.flags) and
                not(nf_modify in taddnode(n).left.flags) and
                is_loop_invariant(currforloop,taddnode(n).right) then
                begin
                  changedforloop:=true;
                  { did we use the same expression before already? }
                  if not(findpreviousstrengthreduction(n)) then
                    begin
{$ifdef DEBUG_OPTSTRENGTH}
                      writeln('**********************************************************************************');
                      writeln(parser_current_file, ': Found expression for strength reduction (MUL): ');
                      printnode(n);
                      writeln('**********************************************************************************');
{$endif DEBUG_OPTSTRENGTH}
                      tempnode:=ctempcreatenode.create(n.resultdef,n.resultdef.size,tt_persistent,
                        tstoreddef(n.resultdef).is_intregable or tstoreddef(n.resultdef).is_fpuregable);
                      addinduction(tempnode,n);

                      if lnf_backward in currforloop.loopflags then
                        addstatement(calccodestatements,
                          geninlinenode(in_dec_x,false,
                          ccallparanode.create(ctemprefnode.create(tempnode),ccallparanode.create(taddnode(n).right.getcopy,nil))))
                      else
                        addstatement(calccodestatements,
                          geninlinenode(in_inc_x,false,
                          ccallparanode.create(ctemprefnode.create(tempnode),ccallparanode.create(taddnode(n).right.getcopy,nil))));

                      addstatement(initcodestatements,tempnode);
                      nn:=currforloop.right.getcopy;
                      { If the calculation is not performed at the end
                        it is needed to adjust the starting value }
                      if not docalcatend then
                        begin
                          if lnf_backward in currforloop.loopflags then
                            nt:=addn
                          else
                            nt:=subn;
                          nn:=caddnode.create_internal(nt,nn,
                             cordconstnode.create(1,nn.resultdef,false));
                        end;
                      addstatement(initcodestatements,cassignmentnode.create(ctemprefnode.create(tempnode),
                          caddnode.create(muln,nn,
                            taddnode(n).right.getcopy)
                          )
                        );

                      { finally replace the node by a temp. ref }
                      n:=ctemprefnode.create(tempnode);

                      { ... and add a temp. release node }
                      addstatement(deletecodestatements,ctempdeletenode.create(tempnode));
                    end;
                  { set types }
                  do_firstpass(n);
                  result:=fen_norecurse_false;
                end;
            end;
          vecn:
            begin
              { is the index the counter variable? }
              if not(is_special_array(tvecnode(n).left.resultdef)) and
                not(is_packed_array(tvecnode(n).left.resultdef)) and
                (tvecnode(n).right.isequal(currforloop.left) or
                 { fpc usually creates a type cast to access an array }
                 ((tvecnode(n).right.nodetype=typeconvn) and
                  ttypeconvnode(tvecnode(n).right).left.isequal(currforloop.left)
                 )
                ) and
                { plain read of the loop variable? }
                not(nf_write in tvecnode(n).right.flags) and
                not(nf_modify in tvecnode(n).right.flags) and
                { direct array access? }
                ((tvecnode(n).left.nodetype=loadn) or
                { ... or loop invariant expression? }
                is_loop_invariant(currforloop,tvecnode(n).right))
{$if not (defined(cpu16bitalu) or defined(cpu8bitalu))}
                { removing the multiplication is only worth the
                  effort if it's not a simple shift }
                and not(ispowerof2(tcgvecnode(n).get_mul_size,dummy))
{$endif}
                then
                begin
                  changedforloop:=true;
                  { did we use the same expression before already? }
                  if not(findpreviousstrengthreduction(n)) then
                    begin
{$ifdef DEBUG_OPTSTRENGTH}
                      writeln('**********************************************************************************');
                      writeln(parser_current_file,': Found expression for strength reduction (VEC): ');
                      printnode(n);
                      writeln('**********************************************************************************');
{$endif DEBUG_OPTSTRENGTH}
                      tempnode:=ctempcreatenode.create(voidpointertype,voidpointertype.size,tt_persistent,true);
                      addinduction(tempnode,n);

                      if lnf_backward in currforloop.loopflags then
                        addstatement(calccodestatements,
                          cinlinenode.createintern(in_dec_x,false,
                          ccallparanode.create(ctemprefnode.create(tempnode),ccallparanode.create(
                          cordconstnode.create(tcgvecnode(n).get_mul_size,sizeuinttype,false),nil))))
                      else
                        addstatement(calccodestatements,
                          cinlinenode.createintern(in_inc_x,false,
                          ccallparanode.create(ctemprefnode.create(tempnode),ccallparanode.create(
                          cordconstnode.create(tcgvecnode(n).get_mul_size,sizeuinttype,false),nil))));

                      addstatement(initcodestatements,tempnode);

                      startvaltemp:=maybereplacewithtemp(currforloop.right,initcode,initcodestatements,currforloop.right.resultdef.size,true);
                      nn:=caddrnode.create(
                          cvecnode.create(tvecnode(n).left.getcopy,ctypeconvnode.create_internal(currforloop.right.getcopy,tvecnode(n).right.resultdef))
                        );
                      { If the calculation is not performed at the end
                        it is needed to adjust the starting value }
                      if not docalcatend then
                        begin
                          if lnf_backward in currforloop.loopflags then
                            nt:=addn
                          else
                            nt:=subn;
                          nn:=caddnode.create_internal(nt,
                             ctypeconvnode.create_internal(nn,voidpointertype),
                             cordconstnode.create(tcgvecnode(n).get_mul_size,sizeuinttype,false));
                        end;
                      addstatement(initcodestatements,cassignmentnode.create(ctemprefnode.create(tempnode),nn));

                      { finally replace the node by a temp. ref }
                      n:=ctypeconvnode.create_internal(cderefnode.create(ctemprefnode.create(tempnode)),n.resultdef);

                      { ... and add a temp. release node }
                      if startvaltemp<>nil then
                        addstatement(deletecodestatements,ctempdeletenode.create(startvaltemp));
                      addstatement(deletecodestatements,ctempdeletenode.create(tempnode));
                    end;
                  { Copy the nf_write,nf_modify flags to the new deref node of the temp.
                    Otherwise assignments to vector elements will be removed. }
                  if nflags*[nf_write,nf_modify]<>[] then
                    begin
                      if (n.nodetype<>typeconvn) or (ttypeconvnode(n).left.nodetype<>derefn) then
                        internalerror(2021091501);
                      ttypeconvnode(n).left.flags:=ttypeconvnode(n).left.flags+nflags*[nf_write,nf_modify];
                    end;
                  { set types }
                  do_firstpass(n);
                  result:=fen_norecurse_false;
                end;
            end;
          else
            ;
        end;
      end;


    function dostrengthreductiontest_callback(var n: tnode; arg: pointer): foreachnoderesult;
      begin
        result:=toptimizeinductionvariablescontext(arg^).dostrengthreductiontest(n);
      end;


    procedure toptimizeinductionvariablescontext.optimizeinductionvariablessingleforloop(var n: tnode);
      var
        loopcode : tblocknode;
        loopcodestatements,
        newcodestatements : tstatementnode;
        newfor,oldn : tnode;
      begin
        { do we have DFA available? }
        if pi_dfaavailable in current_procinfo.flags then
          begin
            CalcDefSum(tfornode(n).t2);
          end;
        currforloop:=tfornode(n);
        initcode:=nil;
        calccode:=nil;
        deletecode:=nil;
        initcodestatements:=nil;
        calccodestatements:=nil;
        deletecodestatements:=nil;
        ninductions:=0;
        docalcatend:=false;
        { find all expressions being candidates for strength reduction
          and replace them }
        foreachnodestatic(pm_postprocess,n,@dostrengthreductiontest_callback,@self);

        { clue everything together }
        if assigned(initcode) then
          begin
            do_firstpass(tnode(initcode));
            do_firstpass(tnode(calccode));
            do_firstpass(tnode(deletecode));
            { create a new for node, the old one will be released by the compiler }
            oldn:=n;
            newfor:=cfornode.create(tfornode(oldn).left,tfornode(oldn).right,tfornode(oldn).t1,tfornode(oldn).t2,lnf_backward in tfornode(oldn).loopflags);
            tfornode(oldn).left:=nil;
            tfornode(oldn).right:=nil;
            tfornode(oldn).t1:=nil;
            tfornode(oldn).t2:=nil;

            loopcode:=internalstatements(loopcodestatements);
            if not docalcatend then
              addstatement(loopcodestatements,calccode);
            addstatement(loopcodestatements,tfornode(newfor).t2);
            if docalcatend then
              addstatement(loopcodestatements,calccode);
            tfornode(newfor).t2:=loopcode;
            do_firstpass(newfor);

            n:=internalstatements(newcodestatements);
            oldn.Free;
            oldn := nil;
            addstatement(newcodestatements,initcode);
            addstatement(newcodestatements,newfor);
            addstatement(newcodestatements,deletecode);
          end;
      end;


    function optimizeinductionvariablessingleforloop_static(var n: tnode; arg: pointer): foreachnoderesult;
      var
        ctx : ^toptimizeinductionvariablescontext absolute arg;
      begin
        Result:=fen_false;
        if n.nodetype<>forn then
          exit;
        ctx^.containsnestedforloop:=false;
        ctx^.optimizeinductionvariablessingleforloop(n);
        { can we avoid further searching? }
        if not(ctx^.containsnestedforloop) then
          Result:=fen_norecurse_false;
      end;


    function OptimizeInductionVariables(node : tnode) : boolean;
      var
        ctx : toptimizeinductionvariablescontext;
      begin
        Result:=false;
        if not(pi_dfaavailable in current_procinfo.flags) then
          exit;
        ctx.changedforloop:=false;
        foreachnodestatic(pm_postprocess,node,@optimizeinductionvariablessingleforloop_static,@ctx);
        Result:=ctx.changedforloop;
      end;


    function recorddirectaccess(var n: tnode; arg: pointer): foreachnoderesult;
      begin
        result:=fen_false;
        case n.nodetype of
          subscriptn:
            if (TSubscriptNode(n).left.nodetype=loadn) and
              (TLoadNode(TSubscriptNode(n).left).symtableentry=TSymEntry(arg)) then
              { It's fine if the record is loaded to access a single field }
              result:=fen_norecurse_false;
          loadn:
            if (TLoadNode(n).symtableentry=TSymEntry(arg)) then
              result:=fen_norecurse_true;
          else
            ;
        end;
      end;


    type
      TFieldTempPair = class(TLinkedListItem)
        BaseSymbol: TAbstractVarSym;
        Field: TFieldVarSym;
        TempCreate: TTempCreateNode;
        InitialRead: Boolean;
        FieldRead: Boolean;
        FieldWritten: Boolean;
        Score: LongInt;
        FirstDepth: Integer;
      end;

      PRecordData = ^TRecordData;
      TRecordData = record
        BaseSymbol: TAbstractVarSym;
        Fields: TLinkedList;
        Depth: Integer;
      end;

    function recordloopfindrefs(var n: tnode; arg: pointer): foreachnoderesult; forward;

    { Needed as we can't reference recordloopfindrefs directly within itself }
    function recordloopfindrefs_recursive(var n: tnode; arg: pointer): foreachnoderesult;
      begin
        result:=recordloopfindrefs(n, arg);
      end;

    function recordloopfindrefs(var n: tnode; arg: pointer): foreachnoderesult;
      var
        ThisTemp: TFieldTempPair;
      begin
        case n.nodetype of
          subscriptn:
            if (TSubscriptNode(n).left.nodetype=loadn) and
              (TLoadNode(TSubscriptNode(n).left).symtableentry=PRecordData(arg)^.BaseSymbol) and
              { Needs to be a basic type }
              not is_string(TSubscriptNode(n).vs.vardef) and
              not is_object(TSubscriptNode(n).vs.vardef) and
              not is_managed_type(TSubscriptNode(n).vs.vardef) and
              (
                (
                  tstoreddef(TSubscriptNode(n).vs.vardef).is_intregable and
                  (TSubscriptNode(n).vs.vardef.size<=sizeof(aint))
                ) or
                tstoreddef(TSubscriptNode(n).vs.vardef).is_fpuregable or
                (
                  is_vector(tstoreddef(TSubscriptNode(n).vs.vardef)) and
                  fits_in_mm_register(tstoreddef(TSubscriptNode(n).vs.vardef))
                )
              ) then
              begin
                { See if we've defined this field already }
                ThisTemp:=TFieldTempPair(PRecordData(arg)^.Fields.First);
                while Assigned(ThisTemp) do
                  begin
                    if (ThisTemp.BaseSymbol=PRecordData(arg)^.BaseSymbol) and
                      (ThisTemp.Field=TSubscriptNode(n).vs) then
                      Break;
                    ThisTemp:=TFieldTempPair(ThisTemp.Next);
                  end;

                if not Assigned(ThisTemp) then
                  begin
                    ThisTemp:=TFieldTempPair.Create;
                    ThisTemp.BaseSymbol:=PRecordData(arg)^.BaseSymbol;
                    ThisTemp.Field:=TSubscriptNode(n).vs;
                    ThisTemp.TempCreate:=CTempCreateNode.Create(TSubscriptNode(n).vs.vardef,TSubscriptNode(n).vs.vardef.size,tt_persistent,True);
                    ThisTemp.InitialRead:=(nf_modify in TLoadNode(TSubscriptNode(n).left).flags) or not (nf_write in TLoadNode(TSubscriptNode(n).left).flags);
                    ThisTemp.FieldWritten:=False;
                    ThisTemp.Score:=0;
                    ThisTemp.FirstDepth:=PRecordData(arg)^.Depth;
                    if not Assigned(PRecordData(arg)^.Fields.Last) then
                      PRecordData(arg)^.Fields.Insert(ThisTemp)
                    else
                      PRecordData(arg)^.Fields.InsertAfter(ThisTemp,PRecordData(arg)^.Fields.Last);
                  end;

                { A write is worth 1.5 times as much as a read under the scoring system }
                if TLoadNode(TSubscriptNode(n).left).flags*[nf_write,nf_modify]<>[] then
                  begin
                    ThisTemp.FieldWritten:=True;
                    Inc(ThisTemp.Score,3);
                    if nf_modify in TLoadNode(TSubscriptNode(n).left).flags then
                      begin
                        ThisTemp.FieldRead:=True;
                        Inc(ThisTemp.Score,2);
                      end;
                  end
                else
                  begin
                    ThisTemp.FieldRead:=True;
                    Inc(ThisTemp.Score,2);
                  end;

                result:=fen_true;
                Exit;
              end;
          else
            if n.InheritsFrom(TLoopNode) then
              begin
                if foreachnodestatic(pm_postprocess, TLoopNode(n).left, @recordloopfindrefs_recursive, arg) then
                  result:=fen_true;

                { Writes inside loops may not get executed, so we need to read an initial value to be safe,
                  hence the incrementation of Depth prior to analysing the right and t1 nodes }
                Inc(PRecordData(arg)^.Depth);
                if foreachnodestatic(pm_postprocess, TLoopNode(n).right, @recordloopfindrefs_recursive, arg) then
                  result:=fen_true;
                if foreachnodestatic(pm_postprocess, TLoopNode(n).t1, @recordloopfindrefs_recursive, arg) then
                  result:=fen_true;

                Dec(PRecordData(arg)^.Depth);
              end;
        end;
        result:=fen_false;
      end;


    function recordloopreplacerefs(var n: tnode; arg: pointer): foreachnoderesult;
      var
        ThisTemp: TFieldTempPair;
        NewNode: TNode;
      begin
        case n.nodetype of
          subscriptn:
            if (TSubscriptNode(n).left.nodetype=loadn) and
              (TLoadNode(TSubscriptNode(n).left).symtableentry.typ in [localvarsym, paravarsym]) then
              begin
                { See if this field has been defined }
                ThisTemp:=TFieldTempPair(PRecordData(arg)^.Fields.First);
                while Assigned(ThisTemp) do
                  begin
                    if (ThisTemp.BaseSymbol=TLoadNode(TSubscriptNode(n).left).symtableentry) and
                      (ThisTemp.Field=TSubscriptNode(n).vs) then
                      Break;
                    ThisTemp:=TFieldTempPair(ThisTemp.Next);
                  end;

                if not Assigned(ThisTemp) then
                  begin
                    { The field should not be replaced }
                    result:=fen_norecurse_false;
                    Exit;
                  end;

                { Now actually replace the node }
                NewNode:=CTempRefNode.Create(ThisTemp.TempCreate);
                NewNode.fileinfo:=n.fileinfo;
                NewNode.flags:=NewNode.flags+(TLoadNode(TSubscriptNode(n).left).flags*[nf_write,nf_modify]);
                n.Free;
                n:=NewNode;
                n.pass_typecheck;
                result:=fen_true;
                Exit;
              end;
          else
            ;
        end;
        result:=fen_false;
      end;


    { Estimate a per-platform register limit to prevent too much register pressure. }
    const
{$if defined(i386) or defined(i8086)}
      RECORD_TEMP_LIMIT = 3;
{$elseif defined(aarch64) or defined(riscv64)}
      RECORD_TEMP_LIMIT = 15;
{$else}
      RECORD_TEMP_LIMIT = 7;
{$endif}

    function discount_temprefs(var n:tnode; arg: pointer): foreachnoderesult;
      begin
        if n.nodetype=temprefn then
          begin
            Dec(PInteger(arg)^);
            result:=fen_norecurse_true;
          end
        else
          result:=fen_false;
      end;


    function _optimize_record_writes(var n:tnode; arg: pointer): foreachnoderesult;
      var
        X, Y, SymCount: Integer;
        MinScore: LongInt;
        CurrentSym: TSym;
        RecordData: TRecordData;
        AbortRecord: Boolean;
        NewBlock: TBlockNode;
        NewWrapper: TStatementNode;
        ThisTemp, NextTemp: TFieldTempPair;
        NewCopy, NewNode: TNode;
        record_limit: Integer;
      begin
        result:=fen_false;
        record_limit:=RECORD_TEMP_LIMIT;

        { Record promotion }
        if (n.nodetype=whilerepeatn) and
          not (nf_internal in n.flags) then
          begin
            if foreachnodestatic(pm_postprocess,n,@discount_temprefs,@record_limit) and
              (record_limit<=0) then
              { Likely no free registers }
              Exit;

            RecordData.Fields:=nil;
            { Check to see if local record-types can have individual fields
              promoted to registers }
            if current_procinfo.procdef.localst.symtabletype = localsymtable then
              begin
                RecordData.Fields:=TLinkedList.Create;
                SymCount:=current_procinfo.procdef.localst.SymList.Count-1;
                for X:=0 to SymCount do
                  begin
                    CurrentSym:=TSym(current_procinfo.procdef.localst.SymList[X]);
                    if (CurrentSym.typ=localvarsym) and
                      { Don't optimise records whose address has been taken,
                        since there may be some multithreaded access going on }
                      (TAbstractVarSym(CurrentSym).varsymaccess*[vsa_addr_taken,vsa_different_scope]=[]) then
                      begin

                        if is_record(TAbstractVarSym(CurrentSym).vardef) then
                          begin
                            { TODO: Support unions in a limited fashion later }
                            if TRecordDef(TAbstractVarSym(CurrentSym).vardef).isunion then
                              Continue;

                            { Ignore records with only a single field, but
                              note they may be regable }
                            if (TRecordDef(TAbstractVarSym(CurrentSym).vardef).symtable.SymList.Count <= 1) then
                              begin
                                Dec(record_limit);
                                Continue;
                              end;

                            AbortRecord:=False;
                            { Make sure an absolute variable doesn't alias to it }
                            for Y:=0 to SymCount do
                              if (X<>Y) and
                                (TSym(current_procinfo.procdef.localst.SymList[X]).typ=absolutevarsym) and
                                (TAbsoluteVarSym(current_procinfo.procdef.localst.SymList[X]).abstyp=tovar) and
                                (TAbsoluteVarSym(current_procinfo.procdef.localst.SymList[X]).ref.firstsym^.sltype=sl_load) and
                                (TAbsoluteVarSym(current_procinfo.procdef.localst.SymList[X]).ref.firstsym^.sym=CurrentSym) then
                                begin
                                  { Don't take any chances }
                                  AbortRecord:=True;
                                  Break;
                                end;

                            if AbortRecord then
                              Continue;

                            { Check to see that the symbol isn't directly accessed as one }
                            if foreachnodestatic(pm_postprocess, n, @recorddirectaccess, CurrentSym) then
                              Continue;

                            RecordData.BaseSymbol:=TAbstractVarSym(CurrentSym);
                            RecordData.Depth:=0;

                            foreachnodestatic(pm_postprocess, n, @recordloopfindrefs, @RecordData);
                          end
                        else if
                          (
                            tstoreddef(TAbstractVarSym(CurrentSym).vardef).is_intregable and
                            (TAbstractVarSym(CurrentSym).vardef.size<=sizeof(aint))
                          ) or
                          tstoreddef(TAbstractVarSym(CurrentSym).vardef).is_fpuregable or
                          (
                            is_vector(tstoreddef(TAbstractVarSym(CurrentSym).vardef)) and
                            fits_in_mm_register(tstoreddef(TAbstractVarSym(CurrentSym).vardef))
                          ) then
                          begin
                            if foreachnodestatic(pm_postprocess, n, @recorddirectaccess, CurrentSym) then
                              { This simple type is likely to become a register, so reduce the limit }
                              Dec(record_limit);
                          end;
                      end;
                  end;

                if (RecordData.Fields.Count > 0) and
                  { If record_limit has gone negative, it may be that there are
                    too many potential regable variables that aren't records,
                    and in extreme cases the count may still be negative even
                    if all of the non-record variables are discounted }
                  (RecordData.Fields.Count + record_limit > 0) then
                  begin
                    { If we have too many record fields to potentially optimise,
                      start excluding ones that give a low return }
                    while (RecordData.Fields.Count > record_limit) do
                      begin
                        MinScore:=$7FFFFFFF;
                        NextTemp:=nil;

                        ThisTemp:=TFieldTempPair(RecordData.Fields.First);
                        while Assigned(ThisTemp) do
                          begin
                            if (ThisTemp.Score<MinScore) then
                              begin
                                NextTemp:=ThisTemp;
                                MinScore:=ThisTemp.Score;
                              end;

                            ThisTemp:=TFieldTempPair(ThisTemp.Next);
                          end;

                        if not Assigned(NextTemp) then
                          { No more temps }
                          Break;

                        TFieldTempPair(NextTemp).TempCreate.Free;
                        RecordData.Fields.Remove(NextTemp);
                      end;

                    { Now that inefficient ones have been removed, replace the subscript nodes }
                    if (RecordData.Fields.Count > 0) and
                      foreachnodestatic(pm_postprocess, n, @recordloopreplacerefs, @RecordData) then
                      begin
                        { Since the loop has had temprefs inserted, put
                          the relevant tempcreates and tempdeletes before
                          and after it. }
                        NewBlock:=internalstatements(NewWrapper);
                        ThisTemp:=TFieldTempPair(RecordData.Fields.First);
                        while Assigned(ThisTemp) do
                          begin
                            ThisTemp.TempCreate.fileinfo:=n.fileinfo;
                            addstatement(NewWrapper, ThisTemp.TempCreate);
                            if ThisTemp.InitialRead or (ThisTemp.FirstDepth<>0) then
                              begin
                                NewNode:=cassignmentnode.create_internal( { Suppress uninitialized value warning }
                                  ctemprefnode.create(
                                    ThisTemp.TempCreate
                                  ),
                                  csubscriptnode.create(
                                    ThisTemp.Field,
                                    cloadnode.create(ThisTemp.BaseSymbol,current_procinfo.procdef.localst)
                                  )
                                );
                                NewNode.fileinfo:=n.fileinfo;
                                addstatement(NewWrapper,NewNode);
                              end;
                            ThisTemp:=TFieldTempPair(ThisTemp.Next);
                          end;

                        { If NewCopy is assigned, then it contains a block
                          created during a previous iteration of this
                          function's for-loop, which includes the original
                          loop node, so insert that instead }
                        NewCopy:=n.getcopy();
                        node_reset_flags(NewCopy,[],[tnf_pass1_done]);
                        Include(NewCopy.flags, nf_internal); { Prevents this simplification pass from happening again }
                        addstatement(NewWrapper, NewCopy);

                        ThisTemp:=TFieldTempPair(RecordData.Fields.Last);
                        while Assigned(ThisTemp) do
                          begin
                            if ThisTemp.FieldWritten then
                              begin
                                { Write the value back to the record }

                                NewNode:=cassignmentnode.create(
                                  csubscriptnode.create(
                                    ThisTemp.Field,
                                    cloadnode.create(ThisTemp.BaseSymbol,current_procinfo.procdef.localst)
                                  ),
                                  ctemprefnode.create(
                                    ThisTemp.TempCreate
                                  )
                                );
                                NewNode.pass_typecheck;
                                NewNode.fileinfo:=n.fileinfo;
                                addstatement(NewWrapper, NewNode);
                              end
                            else
                              { Might produce a more efficient temp }
                              ThisTemp.TempCreate.tempflags:=ThisTemp.TempCreate.tempflags+[ti_const];

                            NewNode:=CTempDeleteNode.create(ThisTemp.TempCreate);
                            NewNode.fileinfo:=n.fileinfo;
                            addstatement(NewWrapper, NewNode);
                            ThisTemp:=TFieldTempPair(ThisTemp.Previous);
                          end;

                        n.Free;
                        n:=NewBlock;
                        n.pass_typecheck;
                        Result:=fen_true;

                        { Keep track of the old block in case more than one
                          local record appears in the loop }
                      end;
                  end;
              end;

            RecordData.Fields.Free;
          end;
      end;

    function optimize_record_writes(var n: tnode): boolean;
      begin
        Result:=foreachnodestatic(pm_preprocess,n,@_optimize_record_writes,nil);
      end;


    type
      toptimizeforloopcontext = object
        changedforloop : boolean;
      end;

    function OptimizeForLoop_iterforloops(var n: tnode; arg: pointer): foreachnoderesult;
      begin
        Result:=fen_false;
        if (n.nodetype=forn) and
          not(lnf_backward in tfornode(n).loopflags) and
          (lnf_dont_mind_loopvar_on_exit in tfornode(n).loopflags) and
          is_constintnode(tfornode(n).right) and
          (([cs_check_overflow,cs_check_range]*n.localswitches)=[]) and
          (([cs_check_overflow,cs_check_range]*tfornode(n).left.localswitches)=[]) and
          ((tfornode(n).left.nodetype=loadn) and (tloadnode(tfornode(n).left).symtableentry is tabstractvarsym) and
            not(tabstractvarsym(tloadnode(tfornode(n).left).symtableentry).addr_taken) and
            not(tabstractvarsym(tloadnode(tfornode(n).left).symtableentry).different_scope)) then
          begin
            { do we have DFA available? }
            if pi_dfaavailable in current_procinfo.flags then
              begin
                CalcUseSum(tfornode(n).t2);
                CalcDefSum(tfornode(n).t2);
              end
            else
              Internalerror(2017122801);
            if not(assigned(tfornode(n).left.optinfo)) then
              exit;
            if not(DynSetIn(tfornode(n).t2.optinfo^.usesum,tfornode(n).left.optinfo^.index)) and
              not(DynSetIn(tfornode(n).t2.optinfo^.defsum,tfornode(n).left.optinfo^.index))  then
              begin
                { convert the loop from i:=a to b into i:=b-a+1 to 1 as this simplifies the
                  abort condition }
{$ifdef DEBUG_OPTFORLOOP}
                writeln('**********************************************************************************');
                writeln('Found loop for reverting: ');
                printnode(n);
                writeln('**********************************************************************************');
{$endif DEBUG_OPTFORLOOP}
                include(tfornode(n).loopflags,lnf_backward);
                tfornode(n).right:=ctypeconvnode.create_internal(
                  caddnode.create_internal(addn,caddnode.create_internal(subn,
                    tfornode(n).t1,tfornode(n).right),
                    cordconstnode.create(1,tfornode(n).left.resultdef,false)),
                  tfornode(n).left.resultdef);
                tfornode(n).t1:=cordconstnode.create(1,tfornode(n).left.resultdef,false);
                include(tfornode(n).loopflags,lnf_counter_not_used);
                exclude(n.transientflags,tnf_pass1_done);
                do_firstpass(n);
{$ifdef DEBUG_OPTFORLOOP}
                writeln('Loop reverted: ');
                printnode(n);
                writeln('**********************************************************************************');
{$endif DEBUG_OPTFORLOOP}
                toptimizeforloopcontext(arg^).changedforloop:=true;
              end;
          end;
      end;


    function OptimizeForLoop(var node : tnode) : boolean;
      var
        ctx : toptimizeforloopcontext;
      begin
        ctx.changedforloop:=false;
        if pi_dfaavailable in current_procinfo.flags then
          foreachnodestatic(pm_postprocess,node,@OptimizeForLoop_iterforloops,@ctx);
        Result:=ctx.changedforloop;
      end;


{*****************************************************************************
                       Loop-invariant code motion (LICM)
*****************************************************************************}

    { LICM hoists side-effect-free, exception-free, loop-invariant
      subexpressions of a loop body into the loop preheader, so they evaluate
      once instead of on every iteration.

      Soundness policy (deliberately conservative -- a wrong hoist is a
      miscompile):
        * only pure, exception-free expression trees are hoisted: plain reads of
          non-aliased local/parameter variables and constants combined with
          +, - and * (no calls, no pointer derefs, no array indexing, no
          div/mod, no range/overflow-checked arithmetic, no volatile/threadvars,
          no property/field access);
        * because the hoisted value cannot trap and has no side effects, it is
          safe to evaluate it in the preheader even when the loop is zero-trip;
        * loop-invariance is proven via the DFA def-set of the whole loop node
          (which, for a for-loop, includes the counter), so any variable
          assigned anywhere in the loop -- including the counter -- disqualifies
          the expression;
        * aliasing is punted on: any variable whose address is taken is treated
          as non-invariant, and pointer/field/index reads are never hoisted, so
          a store through a pointer in the loop cannot invalidate a hoist. }

    type
      tlicmcontext = object
        loopdefsum : tdfaset;
        inittemps,
        deletetemps : tblocknode;
        initstatements,
        deletestatements : tstatementnode;
        nhoists : sizeint;
        hoisted : array of record
          temp : ttempcreatenode;
          expr : tnode;
        end;
        changed : boolean;
        function is_pure_invariant(expr : tnode) : boolean;
        function find_existing_hoist(n : tnode) : ttempcreatenode;
        function hoistcandidate(var n : tnode) : foreachnoderesult;
        procedure processloop(var n : tnode);
      end;


    function licm_contains_load(var n: tnode; arg: pointer): foreachnoderesult;
      begin
        if n.nodetype=loadn then
          begin
            pboolean(arg)^:=true;
            result:=fen_norecurse_true;
          end
        else
          result:=fen_false;
      end;


    { only plain numeric / pointer values may take part in a hoist: this keeps
      managed types (strings, interfaces, variants, dynamic arrays) out, whose
      operators allocate, can raise, or need managed temps -- e.g. "+" on
      strings is concatenation, not arithmetic }
    function licm_simple_type(def : tdef) : boolean;
      begin
        result:=assigned(def) and (def.typ in [orddef,enumdef,floatdef,pointerdef]);
      end;


    { Standalone purity+invariance test shared by LICM and loop unswitching:
      given the DFA def-set of a loop, decides whether an expression tree is a
      pure, non-trapping, loop-invariant numeric/pointer value (see the LICM
      soundness policy above). Kept as a free function so the unswitching pass
      can reuse the exact same analysis rather than duplicating it. }
    function licm_is_pure_invariant(loopdefsum : tdfaset; expr : tnode) : boolean;
      var
        sym : tabstractvarsym;
      begin
        result:=false;
        case expr.nodetype of
          ordconstn,realconstn,pointerconstn,niln:
            result:=true;
          loadn:
            begin
              if not(tloadnode(expr).symtableentry is tabstractvarsym) then
                exit;
              if not licm_simple_type(expr.resultdef) then
                exit;
              sym:=tabstractvarsym(tloadnode(expr).symtableentry);
              result:=
                (sym.typ in [localvarsym,paravarsym]) and
                { plain read, not a write/modify target }
                (([nf_write,nf_modify]*expr.flags)=[]) and
                { no aliasing possible if the address is never taken }
                not(sym.addr_taken) and
                not(sym.different_scope) and
                { volatile and threadvars must be read every time }
                not(vo_volatile in sym.varoptions) and
                not(vo_is_thread_var in sym.varoptions) and
                { must have DFA info and not be defined anywhere in the loop }
                assigned(expr.optinfo) and
                assigned(loopdefsum) and
                not(DynSetIn(loopdefsum,expr.optinfo^.index));
            end;
          typeconvn:
            { a range-checked conversion may raise -> not safe to speculate }
            if (cs_check_range in expr.localswitches) then
              result:=false
            else
              result:=licm_is_pure_invariant(loopdefsum,ttypeconvnode(expr).left);
          addn,subn,muln:
            { checked arithmetic may raise under -Cr/-Co -> not safe to speculate;
              the numeric-result guard keeps string "+" (concatenation) etc. out }
            if licm_simple_type(expr.resultdef) and
               (([cs_check_overflow,cs_check_range]*expr.localswitches)=[]) then
              result:=licm_is_pure_invariant(loopdefsum,taddnode(expr).left) and
                      licm_is_pure_invariant(loopdefsum,taddnode(expr).right);
          unaryminusn:
            if licm_simple_type(expr.resultdef) and
               (([cs_check_overflow,cs_check_range]*expr.localswitches)=[]) then
              result:=licm_is_pure_invariant(loopdefsum,tunarynode(expr).left);
          else
            ;
        end;
      end;


    function tlicmcontext.is_pure_invariant(expr : tnode) : boolean;
      begin
        result:=licm_is_pure_invariant(loopdefsum,expr);
      end;


    function tlicmcontext.find_existing_hoist(n : tnode) : ttempcreatenode;
      var
        i : sizeint;
      begin
        result:=nil;
        for i:=0 to nhoists-1 do
          if hoisted[i].expr.isequal(n) then
            exit(hoisted[i].temp);
      end;


    function tlicmcontext.hoistcandidate(var n : tnode) : foreachnoderesult;
      var
        found : boolean;
        tempnode : ttempcreatenode;
        oldexpr : tnode;
      begin
        result:=fen_false;

        { do not descend into nested loops: their invariants belong to their own
          preheader and are handled when the postorder walk reaches them }
        if n.nodetype in [forn,whilerepeatn] then
          begin
            result:=fen_norecurse_false;
            exit;
          end;

        { only whole arithmetic subexpressions are worth hoisting }
        if not(n.nodetype in [addn,subn,muln]) then
          exit;
        if ([nf_write,nf_modify]*n.flags)<>[] then
          exit;
        if not is_pure_invariant(n) then
          exit;

        { a purely constant expression is already folded; require at least one
          variable read so we actually save work }
        found:=false;
        foreachnodestatic(pm_postprocess,n,@licm_contains_load,@found);
        if not found then
          exit;

        { reuse a temp if we already hoisted an identical expression }
        tempnode:=find_existing_hoist(n);
        if tempnode<>nil then
          begin
            n.free;
            n:=ctemprefnode.create(tempnode);
            do_firstpass(n);
            result:=fen_norecurse_false;
            exit;
          end;

        if not assigned(inittemps) then
          begin
            inittemps:=internalstatements(initstatements);
            deletetemps:=internalstatements(deletestatements);
          end;

        oldexpr:=n;
        tempnode:=ctempcreatenode.create(oldexpr.resultdef,oldexpr.resultdef.size,tt_persistent,
          tstoreddef(oldexpr.resultdef).is_intregable or tstoreddef(oldexpr.resultdef).is_fpuregable);

        addstatement(initstatements,tempnode);
        addstatement(initstatements,cassignmentnode.create(ctemprefnode.create(tempnode),oldexpr));
        addstatement(deletestatements,ctempdeletenode.create(tempnode));

        if nhoists>=length(hoisted) then
          SetLength(hoisted,4+nhoists+nhoists shr 1);
        hoisted[nhoists].temp:=tempnode;
        hoisted[nhoists].expr:=oldexpr;
        inc(nhoists);

        { replace the subtree in the loop body with a reference to the temp }
        n:=ctemprefnode.create(tempnode);
        do_firstpass(n);

        changed:=true;
        result:=fen_norecurse_false;
      end;


    function licm_hoistcandidate_callback(var n: tnode; arg: pointer): foreachnoderesult;
      begin
        result:=tlicmcontext(arg^).hoistcandidate(n);
      end;


    procedure tlicmcontext.processloop(var n : tnode);
      var
        oldn,newn : tnode;
        newstatements : tstatementnode;
      begin
        { compute the def-set of the whole loop node (includes the for-counter) }
        CalcDefSum(n);
        if not assigned(n.optinfo) then
          exit;
        loopdefsum:=n.optinfo^.defsum;

        inittemps:=nil;
        deletetemps:=nil;
        initstatements:=nil;
        deletestatements:=nil;
        nhoists:=0;

        { walk the loop body top-down so the largest invariant subtree wins }
        if n.nodetype=forn then
          foreachnodestatic(pm_preprocess,tfornode(n).t2,@licm_hoistcandidate_callback,@self)
        else
          foreachnodestatic(pm_preprocess,twhilerepeatnode(n).right,@licm_hoistcandidate_callback,@self);

        if not assigned(inittemps) then
          exit;

        do_firstpass(tnode(inittemps));
        do_firstpass(tnode(deletetemps));

        { wrap the loop as: preheader-temps ; loop ; temp-releases }
        oldn:=n;
        newn:=internalstatements(newstatements);
        addstatement(newstatements,inittemps);
        addstatement(newstatements,oldn);
        addstatement(newstatements,deletetemps);
        n:=newn;
      end;


    function licm_processloop_callback(var n: tnode; arg: pointer): foreachnoderesult;
      begin
        result:=fen_false;
        if n.nodetype in [forn,whilerepeatn] then
          tlicmcontext(arg^).processloop(n);
      end;


    function OptimizeLICM(node : tnode) : boolean;
      var
        ctx : tlicmcontext;
      begin
        Result:=false;
        if not(pi_dfaavailable in current_procinfo.flags) then
          exit;
        ctx.changed:=false;
        ctx.nhoists:=0;
        ctx.hoisted:=nil;
        { postorder so nested (inner) loops are processed before their parents }
        foreachnodestatic(pm_postprocess,node,@licm_processloop_callback,@ctx);
        Result:=ctx.changed;
      end;


{*****************************************************************************
                             Loop unswitching
*****************************************************************************}

    { Loop unswitching (gcc's -funswitch-loops): when a conditional inside a
      loop tests a loop-invariant expression, the test is hoisted out of the
      loop and the loop is cloned into a then-variant and an else-variant, so
      each cloned body is branch-free for that test:

          for i:=... do          temp:=<cond>;         // evaluated once
            if <cond> then  -->   if temp then
              A                     for i:=... do A     // branch-free
            else                  else
              B;                    for i:=... do B;    // branch-free

      Soundness policy (a wrong unswitch is a miscompile, so this is
      deliberately conservative and reuses the LICM analysis):
        * the condition must be pure, non-trapping and loop-invariant per the
          DFA def-set of the whole loop node (licm_is_pure_invariant), extended
          only with relational (=,<>,<,<=,>,>=) and boolean-not wrappers, which
          also cannot trap or have side effects; anything else (calls, derefs,
          div/mod, checked arithmetic, addr-taken/volatile/threadvars) is not
          invariant and blocks unswitching;
        * because the condition is pure and non-trapping it is safe to evaluate
          once in the preheader even when the loop is zero-trip;
        * only one if is unswitched per loop (no cascading), and only when the
          loop body fits the size budget below, so cloning cannot blow up;
        * nested loops are unswitched innermost-first (postorder), matching LICM;
        * procedures containing labels are skipped at the call site in psub, as
          strength reduction and LICM do, so goto never crosses a clone
          boundary; break/exit/continue inside a branch stay correct because the
          two clones are mutually exclusive and each is its own loop. }

    const
      { Code-size budget: unswitching duplicates the whole loop body, so only
        do it for bodies of at most this many weighted nodes. Mirrors the
        node_count_weighted heuristic that loop unrolling uses. }
      UNSWITCH_MAX_NODE_WEIGHT = 50;

    type
      tunswitchcontext = object
        loopdefsum : tdfaset;
        condtemp : ptempinfo;
        usethenbranch : boolean;
        foundif : tifnode;
        changed : boolean;
        function is_invariant_cond(expr : tnode) : boolean;
        function findcandidate(var n : tnode) : foreachnoderesult;
        function pickbranch(var n : tnode) : foreachnoderesult;
        procedure processloop(var n : tnode);
      end;


    function tunswitchcontext.is_invariant_cond(expr : tnode) : boolean;
      begin
        result:=false;
        case expr.nodetype of
          equaln,unequaln,ltn,lten,gtn,gten:
            { a relational comparison of two pure invariants is itself pure and
              non-trapping }
            result:=licm_is_pure_invariant(loopdefsum,taddnode(expr).left) and
                    licm_is_pure_invariant(loopdefsum,taddnode(expr).right);
          notn:
            result:=is_invariant_cond(tunarynode(expr).left);
          else
            { a plain boolean flag load, a constant, or invariant arithmetic }
            result:=licm_is_pure_invariant(loopdefsum,expr);
        end;
      end;


    function tunswitchcontext.findcandidate(var n : tnode) : foreachnoderesult;
      begin
        result:=fen_false;
        if assigned(foundif) then
          begin
            result:=fen_norecurse_false;
            exit;
          end;
        { do not descend into nested loops: each is unswitched on its own turn }
        if n.nodetype in [forn,whilerepeatn] then
          begin
            result:=fen_norecurse_false;
            exit;
          end;
        if (n.nodetype=ifn) and
          (([nf_write,nf_modify]*n.flags)=[]) and
          { at least one branch must exist to specialise into }
          (assigned(tifnode(n).right) or assigned(tifnode(n).t1)) and
          is_invariant_cond(tifnode(n).left) then
          begin
            foundif:=tifnode(n);
            result:=fen_norecurse_true;
          end;
      end;


    function tunswitchcontext.pickbranch(var n : tnode) : foreachnoderesult;
      var
        branch : tnode;
        theif : tifnode;
      begin
        result:=fen_false;
        if (n.nodetype=ifn) and
          (tifnode(n).left.nodetype=temprefn) and
          (ttemprefnode(tifnode(n).left).tempinfo=condtemp) then
          begin
            theif:=tifnode(n);
            if usethenbranch then
              begin
                branch:=theif.right;
                theif.right:=nil;
              end
            else
              begin
                branch:=theif.t1;
                theif.t1:=nil;
              end;
            if not assigned(branch) then
              branch:=cnothingnode.create;
            n.free;
            n:=branch;
            result:=fen_norecurse_true;
          end;
      end;


    function unswitch_findcandidate_callback(var n: tnode; arg: pointer): foreachnoderesult;
      begin
        result:=tunswitchcontext(arg^).findcandidate(n);
      end;


    function unswitch_specialize_callback(var n: tnode; arg: pointer): foreachnoderesult;
      begin
        result:=tunswitchcontext(arg^).pickbranch(n);
      end;


    procedure tunswitchcontext.processloop(var n : tnode);
      var
        body,condexpr,clone1,clone2,newn : tnode;
        tempnode : ttempcreatenode;
        newstatements : tstatementnode;
      begin
        { compute the def-set of the whole loop node (includes the for-counter) }
        CalcDefSum(n);
        if not assigned(n.optinfo) then
          exit;
        loopdefsum:=n.optinfo^.defsum;

        if n.nodetype=forn then
          body:=tfornode(n).t2
        else
          body:=twhilerepeatnode(n).right;
        if not assigned(body) then
          exit;

        { size budget: unswitching duplicates the whole body }
        if node_count_weighted(body,UNSWITCH_MAX_NODE_WEIGHT+1)>UNSWITCH_MAX_NODE_WEIGHT then
          exit;

        { find the first loop-invariant if inside the body (one per loop) }
        foundif:=nil;
        foreachnodestatic(pm_preprocess,body,@unswitch_findcandidate_callback,@self);
        if not assigned(foundif) then
          exit;

        { keep the condition tree; it will be evaluated once in the preheader }
        condexpr:=foundif.left;

        tempnode:=ctempcreatenode.create(condexpr.resultdef,condexpr.resultdef.size,tt_persistent,
          tstoreddef(condexpr.resultdef).is_intregable);
        condtemp:=tempnode.tempinfo;

        { mark the target if by pointing its condition at the (unique) temp;
          after cloning, each copy carries an if testing this temp, which lets
          us locate and specialise it in every clone }
        foundif.left:=ctemprefnode.create(tempnode);

        { two specialised copies of the whole loop; the tempcreate is outside
          the copied subtree, so every cloned temp-ref keeps pointing at it }
        clone1:=n.getcopy;
        clone2:=n.getcopy;
        node_reset_flags(clone1,[],[tnf_pass1_done]);
        node_reset_flags(clone2,[],[tnf_pass1_done]);

        { clone1: condition known true -> keep the then-branch }
        usethenbranch:=true;
        foreachnodestatic(pm_preprocess,clone1,@unswitch_specialize_callback,@self);
        { clone2: condition known false -> keep the else-branch }
        usethenbranch:=false;
        foreachnodestatic(pm_preprocess,clone2,@unswitch_specialize_callback,@self);

        { build: temp := cond ; if temp then clone1 else clone2 ; release temp }
        newn:=internalstatements(newstatements);
        addstatement(newstatements,tempnode);
        addstatement(newstatements,cassignmentnode.create(ctemprefnode.create(tempnode),condexpr));
        addstatement(newstatements,cifnode.create(ctemprefnode.create(tempnode),clone1,clone2));
        addstatement(newstatements,ctempdeletenode.create(tempnode));

        { the original loop (with its temp-ref marker) is no longer needed }
        n.free;
        n:=newn;
        do_firstpass(n);
        changed:=true;
      end;


    function unswitch_processloop_callback(var n: tnode; arg: pointer): foreachnoderesult;
      begin
        result:=fen_false;
        if n.nodetype in [forn,whilerepeatn] then
          tunswitchcontext(arg^).processloop(n);
      end;


    function OptimizeLoopUnswitch(node : tnode) : boolean;
      var
        ctx : tunswitchcontext;
      begin
        Result:=false;
        if not(pi_dfaavailable in current_procinfo.flags) then
          exit;
        ctx.changed:=false;
        ctx.foundif:=nil;
        { postorder so nested (inner) loops are unswitched before their parents }
        foreachnodestatic(pm_postprocess,node,@unswitch_processloop_callback,@ctx);
        Result:=ctx.changed;
      end;


{*****************************************************************************
                         Bit-population-count idiom
*****************************************************************************}

    { Recognizes the canonical scalar population-count loop

          while x <> 0 do begin inc(c); x := x and (x - 1) end;

      (the two body statements in either order; for an unsigned x the guard may
      also be written  while x > 0 ) and rewrites it to

          inc(c, PopCnt(x)); x := 0;

      which the backend lowers to a POPCNT instruction when the target CPU
      supports it and to the fpc_popcnt_* RTL routine otherwise.

      The rewrite is value-identical to the loop for every input, including
      x = 0 (the loop is zero-trip, PopCnt(0)=0 and x stays 0) and x with the
      high/sign bit set: each iteration clears the lowest set bit of x and bumps
      c once, so the loop runs exactly PopCnt(x) times and leaves x = 0 -- so
      c ends increased by PopCnt(x) and x ends 0 in both forms.

      Soundness policy (a wrong match is a miscompile, so this is strict):
        * x and c must be *distinct* simple, non-aliased, non-volatile,
          non-threadvar local variables or value parameters of ordinal type,
          exactly 32 or 64 bits wide (other widths are not recognized);
        * the loop body must be exactly the two recognized statements, so x and
          c have no other uses inside the loop;
        * the counter step must be exactly +1 (a plain inc(c) with no amount);
        * only bit-preserving same-size ordinal reinterpret typeconvs are looked
          through, so a narrowing cast such as  while Word(x) <> 0  is never
          mistaken for a full-width test;
        * the  x > 0  guard is accepted only for an unsigned x (a signed x that
          starts negative would skip the loop, which PopCnt would not);
        * procedures containing labels are skipped at the call site in psub. }

    function bitidiom_skip_reinterpret(n : tnode) : tnode;
      { peel bit-preserving same-size ordinal typeconvs (signed<->unsigned and
        equal-width casts); stop at anything that could change value or width }
      begin
        while assigned(n) and (n.nodetype=typeconvn) and
              assigned(ttypeconvnode(n).left) and
              assigned(n.resultdef) and (n.resultdef.typ=orddef) and
              assigned(ttypeconvnode(n).left.resultdef) and
              (ttypeconvnode(n).left.resultdef.typ=orddef) and
              (n.resultdef.size=ttypeconvnode(n).left.resultdef.size) do
          n:=ttypeconvnode(n).left;
        result:=n;
      end;


    function bitidiom_const_value(n : tnode; out v : tconstexprint) : boolean;
      { true if n is an ordinal constant (through any typeconv wrappers, which
        preserve a constant's value); returns the value }
      begin
        while assigned(n) and (n.nodetype=typeconvn) and assigned(ttypeconvnode(n).left) do
          n:=ttypeconvnode(n).left;
        result:=assigned(n) and (n.nodetype=ordconstn);
        if result then
          v:=tordconstnode(n).value;
      end;


    function bitidiom_simple_var(n : tnode) : tabstractvarsym;
      { the referenced var sym if n (after reinterpret peel) is a load of a
        simple non-aliased 32/64-bit ordinal local var or value parameter, else
        nil. Does NOT reject nf_write/nf_modify -- the caller uses it on the
        assignment/inc destinations too. }
      var
        sym : tsym;
        avs : tabstractvarsym;
      begin
        result:=nil;
        n:=bitidiom_skip_reinterpret(n);
        if not assigned(n) or (n.nodetype<>loadn) then
          exit;
        sym:=tloadnode(n).symtableentry;
        if not(sym is tabstractvarsym) then
          exit;
        avs:=tabstractvarsym(sym);
        if not(avs.typ in [localvarsym,paravarsym]) then
          exit;
        if (avs.typ=paravarsym) and (avs.varspez<>vs_value) then
          exit;
        if avs.addr_taken or avs.different_scope then
          exit;
        if (vo_volatile in avs.varoptions) or (vo_is_thread_var in avs.varoptions) then
          exit;
        if not assigned(n.resultdef) or (n.resultdef.typ<>orddef) then
          exit;
        if not(n.resultdef.size in [4,8]) then
          exit;
        result:=avs;
      end;


    function bitidiom_two_statements(body : tnode; out s0, s1 : tnode) : boolean;
      { body must be a block of exactly two statements; returns them in order }
      var
        stmt : tstatementnode;
        cnt : integer;
      begin
        result:=false;
        s0:=nil;
        s1:=nil;
        if not assigned(body) or (body.nodetype<>blockn) then
          exit;
        stmt:=tstatementnode(tblocknode(body).left);
        cnt:=0;
        while assigned(stmt) do
          begin
            if (stmt.nodetype<>statementn) or not assigned(stmt.left) then
              exit;
            case cnt of
              0: s0:=stmt.left;
              1: s1:=stmt.left;
            else
              exit;   { a third statement -> not our idiom }
            end;
            inc(cnt);
            stmt:=tstatementnode(stmt.right);
          end;
        result:=cnt=2;
      end;


    function bitidiom_try(var n : tnode) : boolean;
      var
        wr : twhilerepeatnode;
        cond, s0, s1, xload : tnode;
        cntvar, xvar : tabstractvarsym;
        cv : tconstexprint;
        unsigneddef, xdef : tdef;
        popcntnode, newinc, newasgn, newblk, oldn : tnode;
        newstmts : tstatementnode;
        guarded : boolean;

      function same_var(ld : tnode; v : tabstractvarsym) : boolean;
        begin
          ld:=bitidiom_skip_reinterpret(ld);
          same_var:=assigned(ld) and (ld.nodetype=loadn) and
                    (tloadnode(ld).symtableentry=tsym(v));
        end;

      function unwrap_block(stmt : tnode) : tnode;
        { descend into single-statement blocks -- firstpass wraps a lowered
          inc() in an internalstatements block before this pass runs }
        var
          inner : tstatementnode;
        begin
          while assigned(stmt) and (stmt.nodetype=blockn) do
            begin
              inner:=tstatementnode(tblocknode(stmt).left);
              if not assigned(inner) or (inner.nodetype<>statementn) or
                 assigned(inner.right) or not assigned(inner.left) then
                break;
              stmt:=inner.left;
            end;
          unwrap_block:=stmt;
        end;

      function counter_var(stmt : tnode) : tabstractvarsym;
        { the counter sym if stmt increments a simple var by exactly +1, either
          as a plain inc(c) inline or as  c := c + 1  (inc() lowered by
          firstpass); nil otherwise }
        var
          cp : tcallparanode;
          ld, r, o1, o2 : tnode;
          k : tconstexprint;
          cs : tabstractvarsym;
        begin
          counter_var:=nil;
          stmt:=unwrap_block(stmt);
          if not assigned(stmt) then
            exit;
          if (stmt.nodetype=inlinen) and (tinlinenode(stmt).inlinenumber=in_inc_x) then
            begin
              cp:=tcallparanode(tinlinenode(stmt).left);
              if not assigned(cp) or assigned(cp.right) then
                exit;   { explicit step -> not a plain +1 }
              counter_var:=bitidiom_simple_var(cp.left);
            end
          else if stmt.nodetype=assignn then
            begin
              ld:=tassignmentnode(stmt).left;
              cs:=bitidiom_simple_var(ld);
              if not assigned(cs) then
                exit;
              r:=bitidiom_skip_reinterpret(tassignmentnode(stmt).right);
              if not assigned(r) or (r.nodetype<>addn) then
                exit;
              o1:=taddnode(r).left;
              o2:=taddnode(r).right;
              { one addend is load(c), the other the constant 1 }
              if (same_var(o1,cs) and bitidiom_const_value(o2,k) and (k=1)) or
                 (same_var(o2,cs) and bitidiom_const_value(o1,k) and (k=1)) then
                counter_var:=cs;
            end;
        end;

      function is_xclear(stmt : tnode) : boolean;
        { true if stmt is  x := x and (x - 1)  for the loop's x }
        var
          rhs2, a, b, sub2 : tnode;
          k : tconstexprint;
        begin
          is_xclear:=false;
          stmt:=unwrap_block(stmt);
          if not assigned(stmt) or (stmt.nodetype<>assignn) then
            exit;
          if not same_var(tassignmentnode(stmt).left,xvar) then
            exit;
          rhs2:=bitidiom_skip_reinterpret(tassignmentnode(stmt).right);
          if not assigned(rhs2) or (rhs2.nodetype<>andn) then
            exit;
          a:=taddnode(rhs2).left;
          b:=taddnode(rhs2).right;
          sub2:=nil;
          if same_var(a,xvar) then
            sub2:=bitidiom_skip_reinterpret(b)
          else if same_var(b,xvar) then
            sub2:=bitidiom_skip_reinterpret(a);
          if not assigned(sub2) or (sub2.nodetype<>subn) then
            exit;
          if not same_var(taddnode(sub2).left,xvar) then
            exit;
          if not(bitidiom_const_value(taddnode(sub2).right,k) and (k=1)) then
            exit;
          is_xclear:=true;
        end;

      begin
        result:=false;
        wr:=twhilerepeatnode(n);
        { standard while-do: test-at-begin, not negated (excludes repeat..until) }
        { reject repeat..until (lnf_checknegate): it runs the body at least once,
          so for x=0 it would count 1, not PopCnt(0)=0 }
        if lnf_checknegate in wr.loopflags then exit;
        { A test-at-begin loop is a genuine while-do (zero-trip). A test-at-end
          loop with lnf_checknegate clear is the do-while that -O2's while->
          "if cond then do..while cond" simplification produces; it must be
          guarded by  if x<>0  so the x=0 case stays a no-op after the rewrite. }
        guarded:=not(lnf_testatbegin in wr.loopflags);
        cond:=wr.left;
        if not assigned(cond) then exit;

        { --- condition: x <> 0, or (unsigned) x > 0 --- }
        xload:=nil;
        case cond.nodetype of
          unequaln:
            if bitidiom_const_value(taddnode(cond).right,cv) and (cv=0) then
              xload:=taddnode(cond).left
            else if bitidiom_const_value(taddnode(cond).left,cv) and (cv=0) then
              xload:=taddnode(cond).right;
          gtn:
            { x > 0 -- only meaningful for unsigned x (checked below) }
            if bitidiom_const_value(taddnode(cond).right,cv) and (cv=0) then
              xload:=taddnode(cond).left;
          else
            exit;
        end;
        xvar:=bitidiom_simple_var(xload);
        if not assigned(xvar) then exit;
        xload:=bitidiom_skip_reinterpret(xload);
        xdef:=xload.resultdef;
        if (cond.nodetype=gtn) and is_signed(xdef) then exit;

        { --- body: exactly the x-clear and the counter increment, either order --- }
        if not bitidiom_two_statements(wr.right,s0,s1) then exit;
        if is_xclear(s0) then
          cntvar:=counter_var(s1)
        else if is_xclear(s1) then
          cntvar:=counter_var(s0)
        else
          exit;
        if not assigned(cntvar) or (cntvar=xvar) then exit;

        { ===== all checks passed: build  inc(c, PopCnt(x)); x := 0 ===== }
        if xdef.size=8 then
          unsigneddef:=u64inttype
        else
          unsigneddef:=u32inttype;

        popcntnode:=geninlinenode(in_popcnt_x,false,
          ctypeconvnode.create_internal(xload.getcopy,unsigneddef));
        newinc:=geninlinenode(in_inc_x,false,
          ccallparanode.create(cloadnode.create(cntvar,cntvar.owner),
            ccallparanode.create(popcntnode,nil)));
        newasgn:=cassignmentnode.create(xload.getcopy,
          cordconstnode.create(0,xdef,false));

        newblk:=internalstatements(newstmts);
        addstatement(newstmts,newinc);
        addstatement(newstmts,newasgn);

        { do-while form: keep the zero-trip guard  if <cond> then <rewrite> }
        if guarded then
          newblk:=cifnode.create(cond.getcopy,newblk,nil);

        oldn:=n;
        n:=newblk;
        do_firstpass(n);
        oldn.free;
        result:=true;
      end;


    function bitidiom_callback(var n: tnode; arg: pointer) : foreachnoderesult;
      begin
        result:=fen_false;
        if n.nodetype=whilerepeatn then
          if bitidiom_try(n) then
            begin
              pboolean(arg)^:=true;
              result:=fen_norecurse_false;
            end;
      end;


    function OptimizeBitIdiom(node : tnode) : boolean;
      var
        changed : boolean;
      begin
        changed:=false;
        { postorder so nested (inner) loops are handled before their parents }
        foreachnodestatic(pm_postprocess,node,@bitidiom_callback,@changed);
        Result:=changed;
      end;

end.

