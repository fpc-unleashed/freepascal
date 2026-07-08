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
    function OptimizeRangeElim(node : tnode) : boolean;
    function OptimizeVectorize(node : tnode) : boolean;
    function OptimizeJumpThread(node : tnode) : boolean;
    function OptimizeLoopDistPat(node : tnode) : boolean;
    function OptimizeLoopPeel(node : tnode) : boolean;
    function OptimizeLoopSplit(node : tnode) : boolean;
    function OptimizeLoopFuse(node : tnode) : boolean;
    function OptimizeReassoc(node : tnode) : boolean;
    function OptimizeUnrollJam(node : tnode) : boolean;

  implementation

    uses
      cclasses,cutils,compinnr,cdynset,
      cgbase,
      globtype,globals,constexp,
{$ifdef i386}
      cpuinfo,
{$endif i386}
      verbose,
      symbase,symconst,symdef,symsym,symtype,
      defutil,defcmp,
      nutils,
      nadd,nbas,nflw,ncon,ninl,ncal,nld,nmem,ncnv,nmat,
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
        function is_reducible_loopvar(n : tnode) : boolean;
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


    { True when converting a value of type fromdef to todef cannot change the
      numeric value for any in-range source value, i.e. a strict integer
      widening that is not a signed->unsigned reinterpretation.  Used to see
      through the implicit index/pointer-offset conversions FPC wraps around the
      loop counter, so that a multiply like conv(i)*stride buried inside an array
      index can still be recognised as counter*invariant. }
    function is_value_preserving_int_conv(fromdef,todef : tdef) : boolean;
      begin
        result:=is_ordinal(fromdef) and is_ordinal(todef) and
          (todef.size>fromdef.size) and
          { a signed source widened into an unsigned target changes negative
            values, so that is not value preserving }
          not(is_signed(fromdef) and not(is_signed(todef)));
      end;


    { Recognises the loop counter possibly wrapped in one or more
      value-preserving integer type conversions (as emitted for array
      index / pointer offset arithmetic).  Only a plain read of the
      counter qualifies, and any range/overflow-checked conversion in the
      chain disqualifies it (a checked conversion may trap and must run every
      iteration). }
    function toptimizeinductionvariablescontext.is_reducible_loopvar(n : tnode) : boolean;
      begin
        result:=false;
        while (n.nodetype=typeconvn) do
          begin
            if ([cs_check_overflow,cs_check_range]*n.localswitches)<>[] then
              exit;
            if not is_value_preserving_int_conv(ttypeconvnode(n).left.resultdef,n.resultdef) then
              exit;
            { a plain type conversion only: a write/modify target is never a
              candidate }
            if ([nf_write,nf_modify]*n.flags)<>[] then
              exit;
            n:=ttypeconvnode(n).left;
          end;
        result:=(n.nodetype=loadn) and
          n.isequal(currforloop.left) and
          not(nf_write in n.flags) and
          not(nf_modify in n.flags);
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
            { A range/overflow-checked multiply may trap and must be evaluated
              every iteration, so never turn it into an additive accumulator.
              This also preserves the historic behaviour that -Cr/-Co disable
              this reduction: previously the check-emitting typeconvs happened to
              break the loadn match; now that we deliberately see through
              value-preserving conversions (below) we must gate explicitly. }
            if ([cs_check_overflow,cs_check_range]*n.localswitches)=[] then
            begin
              { The loop counter may appear directly, or (as in an array index /
                pointer offset) wrapped in value-preserving integer conversions;
                is_reducible_loopvar sees through the latter. }
              if is_reducible_loopvar(taddnode(n).right) and
                is_loop_invariant(currforloop,taddnode(n).left) then
                taddnode(n).swapleftright;

              if is_reducible_loopvar(taddnode(n).left) and
                is_loop_invariant(currforloop,taddnode(n).right) then
                begin
                  changedforloop:=true;
                  { did we use the same expression before already? }
                  if not(findpreviousstrengthreduction(n)) then
                    begin
{$ifdef DEBUG_OPTSTRENGTH}
                      writeln('**********************************************************************************');
                      writeln(parser_current_file, ': Found expression for strength reduction (MUL): ');
                      printnode(output,n);
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
                      printnode(output,n);
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
                printnode(output,n);
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
                printnode(output,n);
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


{*****************************************************************************
                  Bit-scan (tzcnt/lzcnt) idiom -- shared helpers
*****************************************************************************}

    { The following helpers recognize the two scalar bit-scan loops

          while (x and 1) = 0 do begin inc(c); x := x shr 1 end;   // count trailing zeros
          while x > 1        do begin inc(c); x := x shr 1 end;    // highest set bit / bsr

      and lower them to the BsfXWord / BsrXWord intrinsics (TZCNT/BSF resp.
      LZCNT/BSR under the CPU feature gate). They deliberately share the strict
      soundness policy of the population-count matcher above (distinct simple
      non-aliased ordinal locals/value-params, body is exactly the two
      recognized statements, counter step is exactly +1), and additionally:

        * the trailing-zeros loop is *infinite* for x=0, so it is lowered only
          when it is enclosed by a dominating  if x<>0 (or unsigned x>0)  test
          that structurally proves x<>0 at the loop -- the guard is kept
          verbatim and only its body replaced, so the x=0 path is byte-for-byte
          unchanged; loops without such a proof are left alone (see
          bitidiom_tzcnt_try);
        * the highest-bit loop is total (zero-trip for x in 0 and 1) but Bsr(0) is
          undefined, so its rewrite is itself guarded by  if x<>0 , which also
          reproduces the loop's x=0 no-op exactly; it is accepted only for an
          unsigned x (a signed negative x would be zero-trip yet Bsr would count
          its bits). }

    function bitidiom_same_var(ld : tnode; v : tabstractvarsym) : boolean;
      begin
        ld:=bitidiom_skip_reinterpret(ld);
        result:=assigned(ld) and (ld.nodetype=loadn) and
                (tloadnode(ld).symtableentry=tsym(v));
      end;


    function bitidiom_scan_var(n : tnode) : tabstractvarsym;
      { same policy as bitidiom_simple_var: a simple non-aliased 32/64-bit
        ordinal local var or value parameter. Narrower (8/16-bit) operands are
        integer-promoted by the front end so their load sits behind a widening
        typeconv that the same-size-only reinterpret peel deliberately does not
        cross -- they therefore fall through to the scalar loop unchanged, as in
        the population-count matcher. }
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


    function bitidiom_unwrap_stmt(stmt : tnode) : tnode;
      { descend into single-statement blocks (firstpass wraps lowered inc() and
        the then-branch of an if in such blocks) }
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
        result:=stmt;
      end;


    function bitidiom_counter_step1(stmt : tnode) : tabstractvarsym;
      { the counter sym if stmt increments a simple var by exactly +1, either as
        a plain inc(c) inline or as  c := c + 1  (inc() lowered by firstpass) }
      var
        cp : tcallparanode;
        ld, r, o1, o2 : tnode;
        k : tconstexprint;
        cs : tabstractvarsym;
      begin
        result:=nil;
        stmt:=bitidiom_unwrap_stmt(stmt);
        if not assigned(stmt) then
          exit;
        if (stmt.nodetype=inlinen) and (tinlinenode(stmt).inlinenumber=in_inc_x) then
          begin
            cp:=tcallparanode(tinlinenode(stmt).left);
            if not assigned(cp) or assigned(cp.right) then
              exit;   { explicit step -> not a plain +1 }
            result:=bitidiom_scan_var(cp.left);
          end
        else if stmt.nodetype=assignn then
          begin
            ld:=tassignmentnode(stmt).left;
            cs:=bitidiom_scan_var(ld);
            if not assigned(cs) then
              exit;
            r:=bitidiom_skip_reinterpret(tassignmentnode(stmt).right);
            if not assigned(r) or (r.nodetype<>addn) then
              exit;
            o1:=taddnode(r).left;
            o2:=taddnode(r).right;
            if (bitidiom_same_var(o1,cs) and bitidiom_const_value(o2,k) and (k=1)) or
               (bitidiom_same_var(o2,cs) and bitidiom_const_value(o1,k) and (k=1)) then
              result:=cs;
          end;
      end;


    function bitidiom_is_shr1(stmt : tnode; xvar : tabstractvarsym) : boolean;
      { true if stmt is  x := x shr 1  for xvar }
      var
        rhs : tnode;
        k : tconstexprint;
      begin
        result:=false;
        stmt:=bitidiom_unwrap_stmt(stmt);
        if not assigned(stmt) or (stmt.nodetype<>assignn) then
          exit;
        if not bitidiom_same_var(tassignmentnode(stmt).left,xvar) then
          exit;
        rhs:=bitidiom_skip_reinterpret(tassignmentnode(stmt).right);
        if not assigned(rhs) or (rhs.nodetype<>shrn) then
          exit;
        if not bitidiom_same_var(tshlshrnode(rhs).left,xvar) then
          exit;
        if not(bitidiom_const_value(tshlshrnode(rhs).right,k) and (k=1)) then
          exit;
        result:=true;
      end;


    function bitidiom_scan_body(body : tnode; xvar : tabstractvarsym; out cntvar : tabstractvarsym) : boolean;
      { body is exactly  inc(c) and  x := x shr 1  in either order; returns the
        counter var (distinct from x) }
      var
        s0, s1 : tnode;
      begin
        result:=false;
        cntvar:=nil;
        if not bitidiom_two_statements(body,s0,s1) then
          exit;
        if bitidiom_is_shr1(s0,xvar) then
          cntvar:=bitidiom_counter_step1(s1)
        else if bitidiom_is_shr1(s1,xvar) then
          cntvar:=bitidiom_counter_step1(s0)
        else
          exit;
        result:=assigned(cntvar) and (cntvar<>xvar);
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




    function bitidiom_scan_loop_parts(node : tnode; out condnode, bodynode : tnode) : boolean;
      { recognizes a scalar loop whose body runs while a condition holds, in
        either the raw test-at-begin  while C do B  form or the -O2-produced
        do-while-in-if form  if C then (do B while C) . On success condnode is
        the loop/guard condition C and bodynode the loop body B (both still
        owned by node -- the caller getcopy's what it keeps and frees node). }
      var
        inner : tnode;
      begin
        result:=false;
        condnode:=nil;
        bodynode:=nil;
        node:=bitidiom_unwrap_stmt(node);
        if not assigned(node) then
          exit;
        if node.nodetype=whilerepeatn then
          begin
            { raw  while C do B : test-at-begin, while-sense }
            if not(lnf_testatbegin in twhilerepeatnode(node).loopflags) then
              exit;
            if lnf_checknegate in twhilerepeatnode(node).loopflags then
              exit;
            condnode:=twhilerepeatnode(node).left;
            bodynode:=twhilerepeatnode(node).right;
            result:=assigned(condnode) and assigned(bodynode);
          end
        else if node.nodetype=ifn then
          begin
            { -O2 form:  if C then (do B while C) , no else branch }
            if assigned(tifnode(node).t1) then
              exit;
            inner:=bitidiom_unwrap_stmt(tifnode(node).right);
            if not assigned(inner) or (inner.nodetype<>whilerepeatn) then
              exit;
            { the inner loop must be a do-while: test-at-end, while-sense }
            if lnf_testatbegin in twhilerepeatnode(inner).loopflags then
              exit;
            if lnf_checknegate in twhilerepeatnode(inner).loopflags then
              exit;
            condnode:=twhilerepeatnode(inner).left;
            bodynode:=twhilerepeatnode(inner).right;
            if not assigned(condnode) or not assigned(bodynode) then
              exit;
            { the entry guard must be exactly the loop condition, so the
              do-while faithfully reproduces  while C do B  (zero-trip when C
              is false at entry) }
            if not assigned(tifnode(node).left) or
               not tifnode(node).left.isequal(condnode) then
              exit;
            result:=true;
          end;
      end;


    function bitidiom_cond_is_even(condnode : tnode; out xvar : tabstractvarsym; out xload : tnode) : boolean;
      { condnode is  (x and 1) = 0 ; returns x's var and its (peeled) load node }
      var
        andpart : tnode;
        cv, k : tconstexprint;
      begin
        result:=false;
        xvar:=nil;
        xload:=nil;
        if not assigned(condnode) or (condnode.nodetype<>equaln) then
          exit;
        if bitidiom_const_value(taddnode(condnode).right,cv) and (cv=0) then
          andpart:=taddnode(condnode).left
        else if bitidiom_const_value(taddnode(condnode).left,cv) and (cv=0) then
          andpart:=taddnode(condnode).right
        else
          exit;
        andpart:=bitidiom_skip_reinterpret(andpart);
        if not assigned(andpart) or (andpart.nodetype<>andn) then
          exit;
        if bitidiom_const_value(taddnode(andpart).right,k) and (k=1) then
          xload:=taddnode(andpart).left
        else if bitidiom_const_value(taddnode(andpart).left,k) and (k=1) then
          xload:=taddnode(andpart).right
        else
          exit;
        xload:=bitidiom_skip_reinterpret(xload);
        xvar:=bitidiom_scan_var(xload);
        result:=assigned(xvar);
      end;


    function bitidiom_cond_is_gt1(condnode : tnode; out xvar : tabstractvarsym; out xload : tnode) : boolean;
      { condnode is  x > 1 ; returns x's var and its (peeled) load node }
      var
        cv : tconstexprint;
      begin
        result:=false;
        xvar:=nil;
        xload:=nil;
        if not assigned(condnode) or (condnode.nodetype<>gtn) then
          exit;
        if not(bitidiom_const_value(taddnode(condnode).right,cv) and (cv=1)) then
          exit;
        xload:=bitidiom_skip_reinterpret(taddnode(condnode).left);
        xvar:=bitidiom_scan_var(xload);
        result:=assigned(xvar);
      end;


    function bitidiom_tzcnt_try(var n : tnode) : boolean;
      { recognizes the count-trailing-zeros scan under a dominating nonzero test

            if x <> 0 then
              while (x and 1) = 0 do begin inc(c); x := x shr 1 end;

        (the inner while may already be the -O2 do-while-in-if form) and
        rewrites the guarded body to

            inc(c, BsfXWord(x));  x := x shr BsfXWord(x);

        The enclosing  if x<>0  (or unsigned x>0) is KEPT verbatim -- it is the
        soundness gate: the scalar loop never terminates for x=0, so we lower to
        a bit-scan only where a dominating nonzero test structurally proves
        x<>0. For x<>0 the lowest set bit sits at index Bsf(x) = trailing-zero
        count < width, so  x shr Bsf(x)  is a valid shift leaving x's remaining
        high bits (the loop's final x), and c is bumped by that same count. Both
        Bsf(x) read the identical pure load of x (inc touches only c). }
      var
        outerif : tifnode;
        condnode, bodynode, guardcond, xload : tnode;
        xvar, cntvar : tabstractvarsym;
        cv : tconstexprint;
        xdef, unsigneddef : tdef;
        newif, newblk, bsf1, bsf2, newinc, newasgn : tnode;
        newstmts : tstatementnode;
      begin
        result:=false;
        outerif:=tifnode(n);
        if assigned(outerif.t1) then
          exit;   { has an else branch -> not our shape }
        { then-branch must be the  (x and 1)=0  scan loop }
        if not bitidiom_scan_loop_parts(outerif.right,condnode,bodynode) then
          exit;
        if not bitidiom_cond_is_even(condnode,xvar,xload) then
          exit;
        if not bitidiom_scan_body(bodynode,xvar,cntvar) then
          exit;
        xdef:=xload.resultdef;
        if not assigned(xdef) or (xdef.typ<>orddef) then
          exit;
        { the outer guard must prove x<>0 :  x<>0  or unsigned  x>0 , same x }
        guardcond:=outerif.left;
        if not assigned(guardcond) then
          exit;
        case guardcond.nodetype of
          unequaln:
            if not((bitidiom_const_value(taddnode(guardcond).right,cv) and (cv=0) and
                    bitidiom_same_var(taddnode(guardcond).left,xvar)) or
                   (bitidiom_const_value(taddnode(guardcond).left,cv) and (cv=0) and
                    bitidiom_same_var(taddnode(guardcond).right,xvar))) then
              exit;
          gtn:
            begin
              if is_signed(xdef) then
                exit;
              if not(bitidiom_const_value(taddnode(guardcond).right,cv) and (cv=0) and
                     bitidiom_same_var(taddnode(guardcond).left,xvar)) then
                exit;
            end;
          else
            exit;
        end;

        { ===== if <guard> then begin inc(c, Bsf(x)); x := x shr Bsf(x) end ===== }
        if xdef.size=8 then
          unsigneddef:=u64inttype
        else
          unsigneddef:=u32inttype;

        bsf1:=geninlinenode(in_bsf_x,false,
          ctypeconvnode.create_internal(xload.getcopy,unsigneddef));
        newinc:=geninlinenode(in_inc_x,false,
          ccallparanode.create(cloadnode.create(cntvar,cntvar.owner),
            ccallparanode.create(bsf1,nil)));
        bsf2:=geninlinenode(in_bsf_x,false,
          ctypeconvnode.create_internal(xload.getcopy,unsigneddef));
        newasgn:=cassignmentnode.create(xload.getcopy,
          cshlshrnode.create(shrn,xload.getcopy,bsf2));

        newblk:=internalstatements(newstmts);
        addstatement(newstmts,newinc);
        addstatement(newstmts,newasgn);

        newif:=cifnode.create(guardcond.getcopy,newblk,nil);
        n:=newif;
        do_firstpass(n);
        outerif.free;
        result:=true;
      end;


    function bitidiom_bsr_try(var n : tnode) : boolean;
      { recognizes the unsigned highest-set-bit scan

            while x > 1 do begin inc(c); x := x shr 1 end;

        (raw, or the -O2 do-while-in-if form) and rewrites it to

            if x <> 0 then begin inc(c, BsrXWord(x)); x := 1 end;

        The loop is zero-trip for x in 0 and 1, hence total (never infinite), so
        it needs no external guard; the emitted  if x<>0  merely avoids the
        undefined Bsr(0) and reproduces the loop's x=0 no-op exactly (for x=1,
        Bsr(1)=0 and x stays 1, matching the zero-trip). Restricted to unsigned
        x: a signed negative x is zero-trip yet Bsr would still count its bits. }
      var
        condnode, bodynode, xload : tnode;
        xvar, cntvar : tabstractvarsym;
        xdef, unsigneddef : tdef;
        bsrnode, newinc, newasgn, newblk, guard, oldn : tnode;
        newstmts : tstatementnode;
      begin
        result:=false;
        if not bitidiom_scan_loop_parts(n,condnode,bodynode) then
          exit;
        if not bitidiom_cond_is_gt1(condnode,xvar,xload) then
          exit;
        if not bitidiom_scan_body(bodynode,xvar,cntvar) then
          exit;
        xdef:=xload.resultdef;
        if not assigned(xdef) or (xdef.typ<>orddef) then
          exit;
        if is_signed(xdef) then
          exit;

        { ===== if x<>0 then begin inc(c, Bsr(x)); x := 1 end ===== }
        if xdef.size=8 then
          unsigneddef:=u64inttype
        else
          unsigneddef:=u32inttype;

        bsrnode:=geninlinenode(in_bsr_x,false,
          ctypeconvnode.create_internal(xload.getcopy,unsigneddef));
        newinc:=geninlinenode(in_inc_x,false,
          ccallparanode.create(cloadnode.create(cntvar,cntvar.owner),
            ccallparanode.create(bsrnode,nil)));
        newasgn:=cassignmentnode.create(xload.getcopy,
          cordconstnode.create(1,xdef,false));

        newblk:=internalstatements(newstmts);
        addstatement(newstmts,newinc);
        addstatement(newstmts,newasgn);

        guard:=cifnode.create(
          caddnode.create(unequaln,xload.getcopy,
            cordconstnode.create(0,xdef,false)),
          newblk,nil);
        oldn:=n;
        n:=guard;
        do_firstpass(n);
        oldn.free;
        result:=true;
      end;


    function bitidiom_callback(var n: tnode; arg: pointer) : foreachnoderesult;
      begin
        result:=fen_false;
        case n.nodetype of
          whilerepeatn:
            if bitidiom_try(n) then
              begin
                pboolean(arg)^:=true;
                result:=fen_norecurse_false;
              end
            else if bitidiom_bsr_try(n) then
              begin
                pboolean(arg)^:=true;
                result:=fen_norecurse_false;
              end;
          ifn:
            if bitidiom_tzcnt_try(n) then
              begin
                pboolean(arg)^:=true;
                result:=fen_norecurse_false;
              end
            else if bitidiom_bsr_try(n) then
              begin
                pboolean(arg)^:=true;
                result:=fen_norecurse_false;
              end;
          else
            { all other node types are irrelevant to the bit idioms; keep
              scanning. An explicit else avoids the "case does not handle all
              possible cases" warning, which -Sew turns into an error when the
              compiler is self-compiled. }
            ;
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


{*****************************************************************************
              Value-range-analysis range-check elimination
*****************************************************************************}

    { The named gcc/LLVM value-range-propagation redundant-check-elimination
      pass, ported (in a deliberately narrow, provably-safe form) to FPC: when
      range checking is on (-Cr), the per-access array bounds check that -Cr
      injects in front of  a[i]  inside a counted for-loop is removed whenever
      the loop counter i is provably always a valid index of the array a.

      The suppression mechanism reuses FPC's own per-node range-check switch:
      the check emitted for  a[i]  is gated on  cs_check_range  being present in
      the node's localswitches at codegen time (pass_2 loads each node's
      localswitches into current_settings.localswitches around
      pass_generate_code). For a *dynamic* array the check
      (fpc_dynarray_rangecheck) is gated on the vecn's own localswitches; for a
      *static* array the check lives in the index -> subrange typeconv child of
      the vecn. So we clear cs_check_range on both the vecn and its index child
      -- exactly the same primitive tvecnode.gen_array_rangecheck already uses
      (nmem.pas: exclude(localswitches,cs_check_range)).

      Exactly two patterns qualify (a wrongly removed check is a memory-safety
      miscompile, so everything else keeps its check):

        A. STATIC array, constant loop bounds within the array's bounds:
             a : array[Lo..Hi] of T;
             for i := c1 to c2 do  ... a[i] ...     ( c1,c2 constants )
           eliminated iff  Lo <= min(c1,c2)  and  max(c1,c2) <= Hi.

        B. DYNAMIC array bounded by its own high()/length()-1:
             for i := k to high(a) do   ... a[i] ...     ( k a constant >= 0 )
           (or  high(a) downto k, or the  length(a)-1  spelling). Because the
           for-loop evaluates its end value once at entry and a is proven not
           reassigned/SetLength'd in the body, length(a) is invariant across the
           loop, so i in [k,high(a)] subset [0,length(a)-1] is always in bounds.
           An empty/NIL a gives high(a) = -1 -> zero-trip -> body never runs.
           Only accesses of that same array a are cleared; a[i+1], a manually
           computed index, or  for i := 0 to length(a)  (no -1, off-by-one) do
           NOT match and keep their check.

      Soundness requirements enforced below (all reuse the neighbouring passes'
      aliasing/DFA analysis):
        * the counter i is a simple, non-aliased, non-volatile local/value-param
          ordinal variable, not assigned anywhere in the loop body (DFA def-set)
          and whose address is never taken;
        * the index expression is exactly a plain read of i (optionally through a
          typeconv), never i+/-offset, and never a different variable;
        * in case B the array a is likewise a simple non-aliased local/value-param
          dynamic array, not assigned in the body (DFA def-set) and not
          address-taken (which also rules out SetLength(a)/by-ref passing);
        * procedures containing labels are skipped at the call site in psub, so
          control can never enter the loop body with i out of range. }

    function rangeelim_skip_typeconv(n : tnode) : tnode;
      { peel typeconv wrappers; the counter index and the loop bounds are often
        wrapped in an internal cast to the counter/index type }
      begin
        while assigned(n) and (n.nodetype=typeconvn) and assigned(ttypeconvnode(n).left) do
          n:=ttypeconvnode(n).left;
        result:=n;
      end;


    function rangeelim_const_value(n : tnode; out v : tconstexprint) : boolean;
      { true (with value) if n is an ordinal constant, through typeconv wrappers
        which preserve a constant's value }
      begin
        n:=rangeelim_skip_typeconv(n);
        result:=assigned(n) and (n.nodetype=ordconstn);
        if result then
          v:=tordconstnode(n).value;
      end;


    function rangeelim_simple_var(n : tnode) : tabstractvarsym;
      { the referenced sym if n is a plain load of a simple, non-aliased,
        non-volatile local variable or value parameter, else nil }
      var
        sym : tsym;
        avs : tabstractvarsym;
      begin
        result:=nil;
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
        result:=avs;
      end;


    function rangeelim_dynhigh_bound(n : tnode; out aload : tnode) : tabstractvarsym;
      { returns the dynamic-array var sym A (and the A-load node) if n computes
        high(A) or length(A)-1 for a simple non-aliased dynamic array A, else
        nil. high(A) = length(A)-1 is the largest valid index of A. Plain
        length(A) is deliberately rejected (that is the off-by-one that must
        keep its check). }
      var
        inner : tnode;
        avs : tabstractvarsym;
        k : tconstexprint;
      begin
        result:=nil;
        aload:=nil;
        n:=rangeelim_skip_typeconv(n);
        if not assigned(n) then
          exit;
        inner:=nil;
        if (n.nodetype=inlinen) and (tinlinenode(n).inlinenumber=in_high_x) then
          inner:=tinlinenode(n).left
        else if n.nodetype=subn then
          begin
            { length(A) - 1 }
            if (rangeelim_skip_typeconv(taddnode(n).left).nodetype=inlinen) and
               (tinlinenode(rangeelim_skip_typeconv(taddnode(n).left)).inlinenumber=in_length_x) and
               rangeelim_const_value(taddnode(n).right,k) and (k=1) then
              inner:=tinlinenode(rangeelim_skip_typeconv(taddnode(n).left)).left;
          end;
        if not assigned(inner) then
          exit;
        inner:=rangeelim_skip_typeconv(inner);
        avs:=rangeelim_simple_var(inner);
        if not assigned(avs) then
          exit;
        if not assigned(inner.resultdef) or not is_dynamic_array(inner.resultdef) then
          exit;
        aload:=inner;
        result:=avs;
      end;


    type
      trangeelimcontext = object
        counter : tabstractvarsym;
        loopbodydefsum : tdfaset;
        haveconst : boolean;
        lo, hi : tconstexprint;        { case A: proven counter range }
        dynsym : tabstractvarsym;      { case B: the high()-bounding array, or nil }
        changed : boolean;
        function index_is_counter(idx : tnode) : boolean;
        function eliminate(var n : tnode) : foreachnoderesult;
        procedure processloop(var n : tnode);
      end;


    function trangeelimcontext.index_is_counter(idx : tnode) : boolean;
      { true if idx is exactly a plain read of the loop counter (optionally
        through a typeconv). An offset like i+1 is an addn -> rejected. }
      begin
        result:=false;
        { the range-check bearing typeconv is peeled; require a plain read }
        if ([nf_write,nf_modify]*idx.flags)<>[] then
          exit;
        idx:=rangeelim_skip_typeconv(idx);
        if not assigned(idx) or (idx.nodetype<>loadn) then
          exit;
        if ([nf_write,nf_modify]*idx.flags)<>[] then
          exit;
        result:=tloadnode(idx).symtableentry=tsym(counter);
      end;


    function trangeelimcontext.eliminate(var n : tnode) : foreachnoderesult;
      var
        adef : tarraydef;
      begin
        result:=fen_false;
        if n.nodetype<>vecn then
          exit;
        if not assigned(tvecnode(n).left) or not assigned(tvecnode(n).left.resultdef) then
          exit;
        { the index must be exactly the loop counter }
        if not index_is_counter(tvecnode(n).right) then
          exit;

        if haveconst then
          begin
            { case A: static array whose [lowrange..highrange] contains [lo..hi] }
            if tvecnode(n).left.resultdef.typ<>arraydef then
              exit;
            if not is_normal_array(tvecnode(n).left.resultdef) then
              exit;
            adef:=tarraydef(tvecnode(n).left.resultdef);
            if not((lo>=adef.lowrange) and (hi<=adef.highrange)) then
              exit;
          end
        else
          begin
            { case B: the very dynamic array whose high() bounds the loop }
            if not assigned(dynsym) then
              exit;
            if tvecnode(n).left.nodetype<>loadn then
              exit;
            if tloadnode(tvecnode(n).left).symtableentry<>tsym(dynsym) then
              exit;
            if not is_dynamic_array(tvecnode(n).left.resultdef) then
              exit;
          end;

        { qualifying access: drop its range check. Clearing on the vecn kills
          the dynamic-array / string check emitted in ncgmem; clearing on the
          index child kills the static-array subrange-typeconv check and the
          dynarray index-widening check. }
        exclude(n.localswitches,cs_check_range);
        if assigned(tvecnode(n).right) then
          exclude(tvecnode(n).right.localswitches,cs_check_range);
        changed:=true;
      end;


    function rangeelim_eliminate_cb(var n : tnode; arg : pointer) : foreachnoderesult;
      begin
        result:=trangeelimcontext(arg^).eliminate(n);
      end;


    procedure trangeelimcontext.processloop(var n : tnode);
      var
        forn_ : tfornode;
        a, b : tconstexprint;
        dynstart, dynend : tabstractvarsym;
        aloadstart, aloadend, achosen : tnode;
      begin
        forn_:=tfornode(n);

        { counter must be a simple, non-aliased local/value-param variable }
        counter:=rangeelim_simple_var(forn_.left);
        if not assigned(counter) then
          exit;

        { DFA: the counter must not be assigned anywhere in the loop body
          (e.g. TP/mac mode allows writing the for-variable) }
        CalcDefSum(forn_.t2);
        if not assigned(forn_.t2.optinfo) or not assigned(forn_.left.optinfo) then
          exit;
        loopbodydefsum:=forn_.t2.optinfo^.defsum;
        if DynSetIn(loopbodydefsum,forn_.left.optinfo^.index) then
          exit;

        haveconst:=false;
        dynsym:=nil;

        if rangeelim_const_value(forn_.right,a) and rangeelim_const_value(forn_.t1,b) then
          begin
            { case A: both loop bounds are ordinal constants }
            haveconst:=true;
            if a<=b then
              begin lo:=a; hi:=b; end
            else
              begin lo:=b; hi:=a; end;
          end
        else
          begin
            { case B: one bound is high(a)/length(a)-1, the other a const >= 0 }
            dynstart:=rangeelim_dynhigh_bound(forn_.right,aloadstart);
            dynend:=rangeelim_dynhigh_bound(forn_.t1,aloadend);
            achosen:=nil;
            if assigned(dynend) and rangeelim_const_value(forn_.right,a) and (a>=0) then
              begin dynsym:=dynend; achosen:=aloadend; end
            else if assigned(dynstart) and rangeelim_const_value(forn_.t1,b) and (b>=0) then
              begin dynsym:=dynstart; achosen:=aloadstart; end
            else
              exit;
            { the array must not be reassigned/SetLength'd inside the loop body:
              addr_taken (already rejected in rangeelim_simple_var) rules out
              SetLength(a) and by-ref passing anywhere in the procedure; the DFA
              def-set rules out a plain  a := ...  in the body }
            if not assigned(achosen.optinfo) then
              exit;
            if DynSetIn(loopbodydefsum,achosen.optinfo^.index) then
              exit;
          end;

        { walk the body clearing the check on every qualifying access }
        foreachnodestatic(pm_preprocess,forn_.t2,@rangeelim_eliminate_cb,@self);
      end;


    function rangeelim_processloop_cb(var n : tnode; arg : pointer) : foreachnoderesult;
      begin
        result:=fen_false;
        if n.nodetype=forn then
          trangeelimcontext(arg^).processloop(n);
      end;


    function OptimizeRangeElim(node : tnode) : boolean;
      var
        ctx : trangeelimcontext;
      begin
        Result:=false;
        if not(pi_dfaavailable in current_procinfo.flags) then
          exit;
        ctx.changed:=false;
        { postorder so nested (inner) loops are handled before their parents }
        foreachnodestatic(pm_postprocess,node,@rangeelim_processloop_cb,@ctx);
        Result:=ctx.changed;
      end;


{*****************************************************************************
                   Conservative loop autovectorization
*****************************************************************************}

    { A deliberately narrow, provably-sound loop autovectorizer ported (in
      miniature) to FPC, which has no autovectorizer at all today. It fires on
      exactly one loop shape -- the canonical single-precision element-wise

           for i := <lo> to <hi> do  a[i] := b[i] <op> c[i]     ( op in + - * )

      where a, b and c are simple, non-aliased dynamic arrays of `single` and i
      is a simple non-aliased signed integer counter -- and rewrites it into a
      128-bit SSE (or AVX, when the fputype has an AVX unit) packed main loop
      that processes VECWIDTH=4 lanes per iteration plus a scalar remainder loop
      that runs the original body for the leftover 0..3 elements:

           lo := <lo>; hi := <hi>; i := lo;
           while i <= hi-3 do begin  (vector) a[i..i+3]:=b[i..i+3] op c[i..i+3];
                                     i := i+4 end;
           while i <= hi   do begin  (scalar) a[i]:=b[i] op c[i]; i := i+1 end;

      Strategy (stated for the commit message): FPC exposes no node-level SIMD
      vector arithmetic (modeswitch arrayoperators does not overload +/-/*
      on  array[0..3] of single , and there is no packed-arithmetic high-level
      cg helper -- a_opmm_ref_reg with shuffle=nil is scalar/logical, only the
      AVX 3-op helper is packed), so Strategy A (rely on node-level vector types)
      is not viable. This is Strategy B: keep the loop *control* as ordinary
      nodes (the two while-loops, the counter compare/increment -- all lowered by
      the existing, well-tested backend) and hand-emit only the 4-lane body from
      a single dedicated backend node (tvectoropnode, x86 override in nx86inl):
      movups/addps|subps|mulps (or the v-forms). The body node reuses the normal
      vecn secondpass to compute the element-i address of each array, then reads
      a full 128-bit window, which keeps the manual codegen to ~6 instructions.

      Soundness (a wrong vectorization is a miscompile, so the recognizer is
      strict; anything not matched compiles exactly as before):
        * COUNTER is a simple, non-aliased, non-volatile, non-address-taken local
          or value-parameter, and a *signed* 32/64-bit integer so hi-3 and i+4
          cannot wrap; DFA additionally proves it is never assigned in the body.
        * BODY is *exactly* one plain (:=, not +=) assignment of the recognized
          shape; the single-statement shape already guarantees a, b, c and i are
          never reassigned in the loop, so no aliasing can be introduced mid-loop.
        * ARRAYS are simple non-aliased dynamic arrays of `single`. Two distinct
          dynamic-array variables either reference the same block at offset 0
          (e.g. after  a := b ) or disjoint blocks -- never a shifted overlap.
          Because every read and the write use the *same* index i, the operation
          is element-wise and therefore alias-safe even when a, b, c share a
          block: the vector load of b[i..i+3] and c[i..i+3] happens before the
          store to a[i..i+3], and each lane computes exactly the scalar value.
          Hence we require no distinctness and emit no runtime overlap guard.
        * The vector loop only advances to i where i+3 <= hi, so the 128-bit
          window never touches an index beyond hi -- the exact same maximum index
          the scalar loop reaches -- so no out-of-bounds over-read is introduced.
        * Range/overflow checking (-Cr/-Co) disables the transform entirely (the
          scalar loop keeps its checks; we do not vectorize checked code), gated
          both on current_settings and by scanning the body for per-region
          check localswitches.
        * FP result is bit-identical to scalar: identical per-lane op in identical
          order, no reassociation -> no fast-math gate needed (NaN/Inf and -0.0
          propagate exactly). Double precision is out of scope (follow-up).
        * The proc must not be an inline candidate (the synthetic node is never
          streamed to a PPU), and -- like the neighbouring loop passes -- procs
          with labels are skipped at the call site in psub. }

    const
      vect_vecwidth = 4;   { single lanes per 128-bit SSE packed op }

    function vect_elem_reason(n : tnode; counter : tabstractvarsym; out vec : tvecnode) : string;
      { returns '' and sets vec to the vecn if n (after peeling typeconv wrappers)
        is  A[i]  where A is a simple non-aliased dynamic array of single and the
        index is exactly a plain read of the loop counter; otherwise returns a
        human-readable reason why it is not such an access (and leaves vec nil).
        The reason strings feed the -OoVECTORIZE diagnostic. }
      var
        vn, idx : tnode;
      begin
        result:='';
        vec:=nil;
        vn:=rangeelim_skip_typeconv(n);
        if not assigned(vn) or (vn.nodetype<>vecn) then
          exit('operand is not an array-element access');
        if not assigned(tvecnode(vn).left) or not assigned(tvecnode(vn).left.resultdef) then
          exit('array base has no known type');
        { the array must be a simple non-aliased dynamic array of single }
        if not assigned(rangeelim_simple_var(tvecnode(vn).left)) then
          exit('array base is not a simple non-aliased variable (possible aliasing)');
        if not is_dynamic_array(tvecnode(vn).left.resultdef) then
          exit('array is not a dynamic array');
        if not is_single(tarraydef(tvecnode(vn).left.resultdef).elementdef) then
          exit('array element type is not single-precision float');
        { the index must be exactly a plain read of the loop counter }
        idx:=rangeelim_skip_typeconv(tvecnode(vn).right);
        if not assigned(idx) or (idx.nodetype<>loadn) then
          exit('array index is not a plain variable read');
        if ([nf_write,nf_modify]*idx.flags)<>[] then
          exit('array index expression has side effects');
        if tloadnode(idx).symtableentry<>tsym(counter) then
          exit('array index is not the loop counter (non-unit stride or offset)');
        vec:=tvecnode(vn);
      end;


    function vect_single_dynarray_elem(n : tnode; counter : tabstractvarsym) : tvecnode;
      { returns the vecn if n (after peeling typeconv wrappers) is  A[i]  where A
        is a simple non-aliased dynamic array of single and the index is exactly a
        plain read of the loop counter; nil otherwise }
      begin
        if vect_elem_reason(n,counter,result)<>'' then
          result:=nil;
      end;


    function vect_invariant_scalar_reason(n : tnode; counter : tabstractvarsym) : string;
      { returns '' if n is a provably loop-invariant single-precision scalar that
        can be broadcast once before the vector loop -- either a constant literal
        or a plain read of a simple non-aliased (non-global, non-address-taken,
        non-volatile) local/value-param that the single-statement body never
        writes -- and n's *own* type is single so the packed op keeps the scalar
        loop's exact precision. Otherwise returns a human-readable reason for the
        -OoVECTORIZE diagnostic. }
      var
        root : tnode;
      begin
        result:='';
        if not assigned(n) or not assigned(n.resultdef) then
          exit('is missing or untyped');
        { the operand must itself be single: a double/integer scalar would make
          the scalar loop compute in a wider precision, so the packed single op
          would not be bit-identical }
        if not is_single(n.resultdef) then
          exit('is not a single-precision value (mixed precision would change the result)');
        if ([nf_write,nf_modify]*n.flags)<>[] then
          exit('has side effects');
        root:=rangeelim_skip_typeconv(n);
        if not assigned(root) then
          exit('is not a constant or a simple loop-invariant variable');
        { a constant literal is trivially loop-invariant }
        if root.nodetype in [ordconstn,realconstn] then
          exit('');
        { or a simple non-aliased local/param: the single-statement body's only
          write is to the destination array element, so such a scalar is never
          assigned in the loop and is provably loop-invariant }
        if root.nodetype=loadn then
          begin
            if not assigned(rangeelim_simple_var(root)) then
              exit('is not a simple non-aliased local/parameter (a global, address-taken or volatile scalar is not proven loop-invariant)');
            if tloadnode(root).symtableentry=tsym(counter) then
              exit('is the loop counter');
            exit('');
          end;
        exit('is not a constant or a simple loop-invariant variable');
      end;


    function vect_body_single_stmt(body : tnode) : tnode;
      { peel block/statement wrappers and return the single meaningful statement
        of a loop body, or nil if there is not exactly one }
      var
        stmt, found : tnode;
      begin
        result:=nil;
        found:=nil;
        if not assigned(body) then
          exit;
        if body.nodetype=blockn then
          body:=tblocknode(body).left;
        if not assigned(body) then
          exit;
        if body.nodetype=statementn then
          begin
            stmt:=body;
            while assigned(stmt) and (stmt.nodetype=statementn) do
              begin
                if assigned(tstatementnode(stmt).left) and
                   (tstatementnode(stmt).left.nodetype<>nothingn) then
                  begin
                    if assigned(found) then
                      exit;   { more than one real statement }
                    found:=tstatementnode(stmt).left;
                  end;
                stmt:=tstatementnode(stmt).right;
              end;
            result:=found;
          end
        else
          result:=body;   { a bare, unwrapped statement }
      end;


    function vect_check_cb(var n : tnode; arg : pointer) : foreachnoderesult;
      { flags a per-region range/overflow check localswitch anywhere in the body }
      begin
        result:=fen_false;
        if ([cs_check_range,cs_check_overflow]*n.localswitches)<>[] then
          begin
            pboolean(arg)^:=true;
            result:=fen_norecurse_true;
          end;
      end;


    type
      tvectorizecontext = object
        changed : boolean;
        procedure processloop(var n : tnode);
      end;


    procedure tvectorizecontext.processloop(var n : tnode);
      var
        forn : tfornode;
        counter : tabstractvarsym;
        ctype : tdef;
        stmt, rhs : tnode;
        assign : tassignmentnode;
        avec, bvec, cvec : tvecnode;
        vecop : TOpCG;
        vshape : tvectoropkind;
        scalarnode : tnode;
        scalarleft : boolean;
        hascheck : boolean;
        block, vecbody, scalbody : tnode;
        stat, vstat, sstat : tstatementnode;
        lotemp, hitemp, splattemp : ttempcreatenode;
        reason : string;
        leftreason, rightreason : string;
        { if-conversion (min/max) recognizer outputs: opA is loaded into the
          destination register, opB is the second (NaN-preferred) operand; each is
          either an array element (mmA/mmB_vec) or an invariant scalar to broadcast
          (mmA/mmB_scalar). splata/splatb hold the broadcast slots when used. }
        mmA_vec, mmB_vec : tvecnode;
        mmA_scalar, mmB_scalar : tnode;
        ismaxop : boolean;
        mminl : tinlinenode;
        splata, splatb : ttempcreatenode;
        windowa, windowb : tnode;

      { Runs the full OptimizeVectorize recognizer over the current for-loop and
        returns '' when the loop can be vectorized (also filling in counter,
        ctype, assign, avec/bvec/cvec and vecop for the builder below), or a
        human-readable reason string naming the first check that failed. Every
        early exit corresponds to a distinct "why not vectorized" reason surfaced
        by the -OoVECTORIZE diagnostic. This runs only while the vectorize pass is
        enabled, so it costs nothing in normal builds. }
      function vectorize_reason : string;
        begin
          result:='';

          { only plain ascending unit-step for-loops }
          if lnf_backward in forn.loopflags then
            exit('descending (downto) loop');
          if assigned(forn.loopstep) then
            exit('non-unit loop step');

          { the counter must be a simple, non-aliased, signed 32/64-bit
            local/value-param variable (so hi-3 / i+VL cannot wrap) }
          counter:=rangeelim_simple_var(forn.left);
          if not assigned(counter) then
            exit('loop counter is not a simple non-aliased variable');
          ctype:=forn.left.resultdef;
          if not assigned(ctype) or (ctype.typ<>orddef) then
            exit('loop counter is not an ordinal type');
          if not is_signed(ctype) or not(ctype.size in [4,8]) then
            exit('loop counter is not a signed 32/64-bit integer');

          { never emit the synthetic body node into an inline-candidate proc: it
            must not be streamed into inline info / a PPU }
          if po_inline in current_procinfo.procdef.procoptions then
            exit('enclosing routine is an inline candidate');

          { preserve bounds/overflow checking: do not vectorize checked code }
          if ([cs_check_range,cs_check_overflow]*current_settings.localswitches)<>[] then
            exit('range/overflow checking is enabled (-Cr/-Co)');

          { the body must be exactly one plain  a[i] := b[i] op c[i]  assignment }
          stmt:=vect_body_single_stmt(forn.t2);
          if not assigned(stmt) then
            exit('loop body is empty or has multiple statements');
          if stmt.nodetype<>assignn then
            exit('loop body is not a single assignment statement');
          assign:=tassignmentnode(stmt);
          if assign.assigntype<>at_normal then
            exit('loop body assignment is not a plain assignment');

          { belt-and-suspenders: bail if any body node carries a per-region
            range/overflow check even when the proc default has none }
          hascheck:=false;
          foreachnodestatic(pm_postprocess,forn.t2,@vect_check_cb,@hascheck);
          if hascheck then
            exit('loop body contains range/overflow-checked code');

          { LHS: a single-precision dynamic-array element  a[i] }
          result:=vect_elem_reason(assign.left,counter,avec);
          if result<>'' then
            exit('destination '+result);

          { RHS: one of the recognized element-wise shapes.  Defaults for the
            fields the builder reads: }
          bvec:=nil; cvec:=nil; scalarnode:=nil; scalarleft:=false;
          vecop:=OP_NONE;
          mmA_vec:=nil; mmB_vec:=nil; mmA_scalar:=nil; mmB_scalar:=nil;
          ismaxop:=false;

          rhs:=rangeelim_skip_typeconv(assign.right);

          { if-conversion shape (-OoIFCONVERT):  a[i] := max/min(u,v)  where FPC's
            -O2 if-conversion has already lowered a branch-predicated ReLU / one-
            sided clamp / element-wise max-min into a single-precision min/max
            intrinsic.  u = opA is the first parameter (loaded into the destination
            register); v = opB is the second, NaN-preferred parameter (the min/max
            node's parameter-list head).  Each operand is either an array element
            of the loop counter or a provably loop-invariant single scalar. }
          if assigned(rhs) and (rhs.nodetype=inlinen) and
             (tinlinenode(rhs).inlinenumber in [in_min_single,in_max_single]) then
            begin
              if not(cs_opt_ifconvert in current_settings.optimizerswitches) then
                exit('min/max activation body but -OoIFCONVERT is disabled');
              mminl:=tinlinenode(rhs);
              if not assigned(mminl.left) or (mminl.left.nodetype<>callparan) or
                 not assigned(tcallparanode(mminl.left).nextpara) or
                 (tcallparanode(mminl.left).nextpara.nodetype<>callparan) or
                 assigned(tcallparanode(tcallparanode(mminl.left).nextpara).nextpara) then
                exit('min/max intrinsic is not a plain two-operand call');
              ismaxop:=mminl.inlinenumber=in_max_single;
              { opB = parameter-list head (second logical arg, NaN-preferred),
                opA = next parameter (first logical arg, loaded into dest reg) }
              rhs:=tcallparanode(mminl.left).paravalue;                              { opB }
              { classify opB }
              if vect_elem_reason(rhs,counter,mmB_vec)<>'' then
                begin
                  result:=vect_invariant_scalar_reason(rhs,counter);
                  if result<>'' then
                    exit('min/max second operand is not an array element or loop-invariant single scalar (it '+result+')');
                  mmB_scalar:=rhs; mmB_vec:=nil;
                end;
              rhs:=tcallparanode(tcallparanode(mminl.left).nextpara).paravalue;       { opA }
              { classify opA }
              if vect_elem_reason(rhs,counter,mmA_vec)<>'' then
                begin
                  result:=vect_invariant_scalar_reason(rhs,counter);
                  if result<>'' then
                    exit('min/max first operand is not an array element or loop-invariant single scalar (it '+result+')');
                  mmA_scalar:=rhs; mmA_vec:=nil;
                end;
              vshape:=vok_minmax;
            end
          { plain copy:  a[i] := b[i] }
          else if (cs_opt_vectorize in current_settings.optimizerswitches) and
                  (vect_elem_reason(assign.right,counter,bvec)='') then
            begin
              vshape:=vok_copy;
            end
          else
            begin
              if not(cs_opt_vectorize in current_settings.optimizerswitches) then
                exit('right-hand side is not a recognized if-conversion (min/max) shape and -OoVECTORIZE is disabled');
              { arithmetic:  b[i] op c[i] ,  b[i] op s ,  or  s op b[i]  (op in + - *) }
              rhs:=rangeelim_skip_typeconv(assign.right);
              if not assigned(rhs) or not(rhs.nodetype in [addn,subn,muln]) then
                exit('right-hand side is not an array element, a copy, or a +, - or * of an array element with an array element or loop-invariant single scalar');
              if ([nf_write,nf_modify]*rhs.flags)<>[] then
                exit('right-hand side has side effects');
              if not assigned(rhs.resultdef) or not is_single(rhs.resultdef) then
                exit('right-hand side is not computed in single precision');
              case rhs.nodetype of
                addn: vecop:=OP_ADD;
                subn: vecop:=OP_SUB;
                muln: vecop:=OP_IMUL;
                else
                  exit('unsupported arithmetic operator');
              end;

              { classify each operand as an array element of the loop counter }
              leftreason:=vect_elem_reason(taddnode(rhs).left,counter,bvec);
              rightreason:=vect_elem_reason(taddnode(rhs).right,counter,cvec);

              if (leftreason='') and (rightreason='') then
                { array op array }
                vshape:=vok_arr_arr
              else if leftreason='' then
                begin
                  { b[i] op s : the right operand must be a loop-invariant single
                    scalar (broadcast once and applied per lane). bvec is already
                    the left array element. }
                  result:=vect_invariant_scalar_reason(taddnode(rhs).right,counter);
                  if result<>'' then
                    exit('second operand is not an array element or provably loop-invariant single scalar (it '+result+')');
                  scalarnode:=taddnode(rhs).right;
                  scalarleft:=false;
                  cvec:=nil;
                  vshape:=vok_arr_scalar;
                end
              else if rightreason='' then
                begin
                  { s op b[i] : the left operand must be a loop-invariant single
                    scalar; move the (right) array element into bvec. Non-
                    commutative subtraction stays  s - b[i]  via scalarleft. }
                  result:=vect_invariant_scalar_reason(taddnode(rhs).left,counter);
                  if result<>'' then
                    exit('first operand is not an array element or provably loop-invariant single scalar (it '+result+')');
                  scalarnode:=taddnode(rhs).left;
                  scalarleft:=true;
                  bvec:=cvec;
                  cvec:=nil;
                  vshape:=vok_arr_scalar;
                end
              else
                { neither operand is a usable array element of the loop counter }
                exit('first source '+leftreason);
            end;

          { DFA: the counter must not be assigned anywhere in the body (on top of
            the single-assignment shape, which already implies it) }
          CalcDefSum(forn.t2);
          if not assigned(forn.t2.optinfo) or not assigned(forn.left.optinfo) then
            exit('data-flow information is unavailable for the loop body');
          if DynSetIn(forn.t2.optinfo^.defsum,forn.left.optinfo^.index) then
            exit('loop counter is modified inside the loop body');
        end;

      begin
        forn:=tfornode(n);

        { The recognizer results below are filled in by the nested
          vectorize_reason function. Per-procedure DFA cannot see that a nested
          routine assigns these parent locals, so at -O4 it reports each of them
          as "not initialized" where the body reads them (and -Sew turns that
          into a build error during an -O4 self-compile). They are always set on
          the reason='' success path; initialize them here so the DFA warning is
          suppressed without changing behaviour. }
        counter:=nil;
        ctype:=nil;
        avec:=nil;
        bvec:=nil;
        cvec:=nil;
        scalarnode:=nil;
        scalarleft:=false;
        vecop:=OP_NONE;
        vshape:=vok_arr_arr;
        mmA_vec:=nil;
        mmB_vec:=nil;
        mmA_scalar:=nil;
        mmB_scalar:=nil;
        ismaxop:=false;
        mminl:=nil;

        { recognize; on failure report the reason and leave codegen untouched }
        reason:=vectorize_reason;
        if reason<>'' then
          begin
            MessagePos1(forn.fileinfo,cg_n_loop_not_vectorized,reason);
            exit;
          end;

        { ---- build the replacement statement block ---- }
        block:=internalstatements(stat);

        { lo := <start>;  hi := <end>   (loop bounds evaluated once, as the
          original for-loop does) }
        lotemp:=ctempcreatenode.create(ctype,ctype.size,tt_persistent,true);
        addstatement(stat,lotemp);
        addstatement(stat,cassignmentnode.create(ctemprefnode.create(lotemp),forn.right.getcopy));

        hitemp:=ctempcreatenode.create(ctype,ctype.size,tt_persistent,true);
        addstatement(stat,hitemp);
        addstatement(stat,cassignmentnode.create(ctemprefnode.create(hitemp),forn.t1.getcopy));

        { i := lo }
        addstatement(stat,cassignmentnode.create(
          cloadnode.create(tsym(counter),counter.owner),
          ctemprefnode.create(lotemp)));

        { scalar-broadcast shape: allocate a 16-byte slot and fill it ONCE with
          [s,s,s,s] before the vector loop (hoisted), so the packed op reads the
          identical scalar bit pattern in every lane on every iteration }
        splattemp:=nil;
        if vshape=vok_arr_scalar then
          begin
            { allowreg=false: the slot must be memory-backed so the hoisted
              broadcast can movups-store it and the loop body movups-load it }
            splattemp:=ctempcreatenode.create(
              tarraydef.getreusable_vector(s32floattype,vect_vecwidth),
              vect_vecwidth*s32floattype.size,tt_persistent,false);
            addstatement(stat,splattemp);
            addstatement(stat,cvectoropnode.create_broadcast(
              ctemprefnode.create(splattemp),scalarnode.getcopy));
          end;

        { if-conversion (vok_minmax): each min/max operand is either an array
          element window or an invariant scalar broadcast once into a splat slot.
          Build windowa/windowb (the packed operand nodes) accordingly. }
        splata:=nil; splatb:=nil; windowa:=nil; windowb:=nil;
        if vshape=vok_minmax then
          begin
            if assigned(mmA_vec) then
              windowa:=mmA_vec.getcopy
            else
              begin
                splata:=ctempcreatenode.create(
                  tarraydef.getreusable_vector(s32floattype,vect_vecwidth),
                  vect_vecwidth*s32floattype.size,tt_persistent,false);
                addstatement(stat,splata);
                addstatement(stat,cvectoropnode.create_broadcast(
                  ctemprefnode.create(splata),mmA_scalar.getcopy));
                windowa:=ctemprefnode.create(splata);
              end;
            if assigned(mmB_vec) then
              windowb:=mmB_vec.getcopy
            else
              begin
                splatb:=ctempcreatenode.create(
                  tarraydef.getreusable_vector(s32floattype,vect_vecwidth),
                  vect_vecwidth*s32floattype.size,tt_persistent,false);
                addstatement(stat,splatb);
                addstatement(stat,cvectoropnode.create_broadcast(
                  ctemprefnode.create(splatb),mmB_scalar.getcopy));
                windowb:=ctemprefnode.create(splatb);
              end;
          end;

        { vector loop:  while i <= hi-(VL-1) do begin <packed body>; i := i+VL end }
        vecbody:=internalstatements(vstat);
        case vshape of
          vok_arr_arr:
            addstatement(vstat,cvectoropnode.create(avec.getcopy,bvec.getcopy,cvec.getcopy,vecop,vect_vecwidth));
          vok_arr_scalar:
            addstatement(vstat,cvectoropnode.create_scalar(avec.getcopy,bvec.getcopy,
              ctemprefnode.create(splattemp),vecop,scalarleft,vect_vecwidth));
          vok_copy:
            addstatement(vstat,cvectoropnode.create_copy(avec.getcopy,bvec.getcopy,vect_vecwidth));
          vok_minmax:
            addstatement(vstat,cvectoropnode.create_minmax(avec.getcopy,windowa,windowb,ismaxop,vect_vecwidth));
          else
            internalerror(2026070706);
        end;
        addstatement(vstat,cassignmentnode.create(
          cloadnode.create(tsym(counter),counter.owner),
          caddnode.create(addn,cloadnode.create(tsym(counter),counter.owner),
            cordconstnode.create(vect_vecwidth,ctype,false))));
        addstatement(stat,cwhilerepeatnode.create(
          caddnode.create(lten,cloadnode.create(tsym(counter),counter.owner),
            caddnode.create(subn,ctemprefnode.create(hitemp),
              cordconstnode.create(vect_vecwidth-1,ctype,false))),
          vecbody,true,false));

        { scalar remainder:  while i <= hi do begin <original body>; i := i+1 end }
        scalbody:=internalstatements(sstat);
        addstatement(sstat,forn.t2.getcopy);
        addstatement(sstat,cassignmentnode.create(
          cloadnode.create(tsym(counter),counter.owner),
          caddnode.create(addn,cloadnode.create(tsym(counter),counter.owner),
            cordconstnode.create(1,ctype,false))));
        addstatement(stat,cwhilerepeatnode.create(
          caddnode.create(lten,cloadnode.create(tsym(counter),counter.owner),
            ctemprefnode.create(hitemp)),
          scalbody,true,false));

        { release the bound temps after their last use }
        addstatement(stat,ctempdeletenode.create(lotemp));
        addstatement(stat,ctempdeletenode.create(hitemp));
        if assigned(splattemp) then
          addstatement(stat,ctempdeletenode.create(splattemp));
        if assigned(splata) then
          addstatement(stat,ctempdeletenode.create(splata));
        if assigned(splatb) then
          addstatement(stat,ctempdeletenode.create(splatb));

        do_firstpass(block);
        if vshape=vok_minmax then
          MessagePos1(forn.fileinfo,cg_n_loop_ifconverted,tostr(vect_vecwidth))
        else
          MessagePos1(forn.fileinfo,cg_n_loop_vectorized,tostr(vect_vecwidth));
        forn.free;
        n:=block;
        changed:=true;
      end;


    function vect_processloop_cb(var n : tnode; arg : pointer) : foreachnoderesult;
      begin
        result:=fen_false;
        if n.nodetype=forn then
          begin
            tvectorizecontext(arg^).processloop(n);
            { n may now be a block; do not recurse into the freed for-node }
            result:=fen_norecurse_false;
          end;
      end;


    function OptimizeVectorize(node : tnode) : boolean;
      var
        ctx : tvectorizecontext;
      begin
        Result:=false;
        if not(pi_dfaavailable in current_procinfo.flags) then
          exit;
        ctx.changed:=false;
        { postorder so nested (inner) loops are considered before their parents }
        foreachnodestatic(pm_postprocess,node,@vect_processloop_cb,@ctx);
        Result:=ctx.changed;
      end;


{*****************************************************************************
       Loop-distribution pattern idiom recognition (fill / zero / copy)
*****************************************************************************}

    { A node-level port of gcc's -ftree-loop-distribute-patterns.  It fires when
      a counted, unit-stride, ascending for-loop's *entire* body is a single
      store that walks a contiguous array region -- either filling every element
      with a loop-invariant value or copying it element-wise from a second array
      -- and lowers the whole loop to the RTL block primitive the C runtime
      already tunes per target:

        for i := lo to hi do a[i] := 0;          ->  FillChar(a[lo], n*sz, 0)
        for i := lo to hi do a[i] := v;          ->  FillDWord(a[lo], n, v)  (sz=4)
        for i := lo to hi do a[i] := b[i];       ->  Move(b[lo], a[lo], n*sz)

      where n = hi-lo+1 (guarded by  if lo <= hi , since a for-loop runs zero
      times when lo > hi and the byte count must not be computed from a negative
      difference).

      Soundness (a wrong lowering is a miscompile, so the recognizer is strict;
      anything not matched compiles exactly as before):
        * COUNTER is a simple, non-aliased, non-volatile, non-address-taken local
          or value-parameter and a signed 32/64-bit integer, proven by DFA to be
          unassigned in the body.  Only ascending unit-step loops are handled
          (downto and non-unit step are declined).
        * BODY is exactly one plain (:=) assignment; the single-statement shape
          guarantees the counter and every base is never reassigned mid-loop.
        * The destination is a[i] where the index is *exactly* a plain read of
          the counter (unit stride, no offset) and a is a plain dynamic array or
          a normal (non-open, non-bitpacked) static array whose base expression
          is a side-effect-free, counter-independent (hence loop-invariant) l-
          value -- so a[lo] can be evaluated once.  The element type must be an
          unmanaged type (managed strings/interfaces/dynarray/variant elements
          are declined) so a raw block operation preserves refcount semantics.
        * FILL value is loop-invariant (a constant or a simple non-aliased
          local/param the body never writes).  A constant zero (ordinal 0, nil,
          or +0.0 -- never -0.0) lowers to FillChar over the byte span, which is
          correct for every element size.  A non-zero fill of an ordinal/pointer
          element of size 1/2/4/8 lowers to FillChar/FillWord/FillDWord/FillQWord
          with the value reinterpreted to the matching unsigned width, which
          writes the identical bytes the scalar store would.  Non-zero float
          fills are declined (a float->integer cast would round, not reinterpret).
        * COPY  a[i] := b[i]  lowers to Move only when *both* a and b are plain
          dynamic arrays indexed by the same counter with identical element type
          and no type conversion on the source.  Two dynamic-array references can
          only fully alias (share the block at offset 0, after  a:=b ) or be
          disjoint -- a shifted overlap is impossible -- so Move (which is memmove
          safe) reproduces the forward element copy exactly in both cases; hence
          no runtime distinctness guard is needed.  Static arrays / pointers can
          shift-overlap and are declined for the copy case.
        * Range/overflow checking (-Cr/-Co) disables the transform (the scalar
          loop keeps its checks), gated on current_settings and by scanning the
          body for per-region check localswitches.
        * The byte/element count is computed in SizeInt so  n*sz  cannot wrap the
          counter type, and the destination address plus count never exceed the
          region the scalar loop's maximum index hi already reached.
        * procs with labels are skipped at the call site in psub (like the other
          loop passes); inline candidates are declined so no synthetic call is
          streamed into inline info. }

    type
      tdistpatkind = (
        dpk_fillchar_zero,   { FillChar over the byte span, value 0 }
        dpk_fillchar,        { FillChar, 1-byte element, value byte }
        dpk_fillword,        { FillWord,  2-byte element }
        dpk_filldword,       { FillDWord, 4-byte element }
        dpk_fillqword,       { FillQWord, 8-byte element }
        dpk_move             { Move over the byte span }
      );

      tdistpat_basecheck = record
        counter : tabstractvarsym;
        bad : boolean;
      end;
      pdistpat_basecheck = ^tdistpat_basecheck;


    function distpat_basecheck_cb(var n : tnode; arg : pointer) : foreachnoderesult;
      { rejects an array-base subtree that is not a pure, counter-independent
        read: any write/modify, any call (or as-cast, which can raise), or any
        reference to the loop counter makes the base non-invariant / unsafe to
        hoist to a single evaluation }
      begin
        result:=fen_false;
        if ([nf_write,nf_modify]*n.flags)<>[] then
          begin
            pdistpat_basecheck(arg)^.bad:=true;
            exit(fen_norecurse_true);
          end;
        case n.nodetype of
          calln,asn:
            begin
              pdistpat_basecheck(arg)^.bad:=true;
              result:=fen_norecurse_true;
            end;
          loadn:
            if tloadnode(n).symtableentry=tsym(pdistpat_basecheck(arg)^.counter) then
              begin
                pdistpat_basecheck(arg)^.bad:=true;
                result:=fen_norecurse_true;
              end;
          else
            ;
        end;
      end;


    function distpat_elem(n : tnode; counter : tabstractvarsym; out vec : tvecnode;
                          out elemdef : tdef; out isdyn : boolean) : string;
      { returns '' and fills vec/elemdef/isdyn when n (after peeling typeconv
        wrappers) is  A[i]  over a contiguous array region: A a plain dynamic or
        normal static array with an unmanaged element, indexed by exactly a plain
        read of the loop counter, whose base is a side-effect-free counter-
        independent l-value.  Otherwise returns a human-readable reason. }
      var
        vn, idx : tnode;
        ad : tdef;
        bc : tdistpat_basecheck;
      begin
        result:='';
        vec:=nil;
        elemdef:=nil;
        isdyn:=false;
        vn:=rangeelim_skip_typeconv(n);
        if not assigned(vn) or (vn.nodetype<>vecn) then
          exit('operand is not an array-element access');
        if not assigned(tvecnode(vn).left) or not assigned(tvecnode(vn).left.resultdef) then
          exit('array base has no known type');
        ad:=tvecnode(vn).left.resultdef;
        if is_dynamic_array(ad) then
          isdyn:=true
        else if is_normal_array(ad) and not is_packed_array(ad) then
          isdyn:=false
        else
          exit('destination is not a plain dynamic or normal static array');
        elemdef:=tarraydef(ad).elementdef;
        if not assigned(elemdef) then
          exit('array element type is unknown');
        if is_managed_type(elemdef) then
          exit('array element type is managed (string/interface/dynarray/variant)');
        if elemdef.size=0 then
          exit('array element has zero size');
        { index must be exactly a plain read of the loop counter (unit stride) }
        idx:=rangeelim_skip_typeconv(tvecnode(vn).right);
        if not assigned(idx) or (idx.nodetype<>loadn) then
          exit('array index is not a plain variable read (non-unit stride or offset)');
        if ([nf_write,nf_modify]*idx.flags)<>[] then
          exit('array index expression has side effects');
        if tloadnode(idx).symtableentry<>tsym(counter) then
          exit('array index is not the loop counter (non-unit stride or offset)');
        { base must be side-effect free and independent of the counter }
        bc.counter:=counter;
        bc.bad:=false;
        foreachnodestatic(pm_postprocess,tvecnode(vn).left,@distpat_basecheck_cb,@bc);
        if bc.bad then
          exit('array base is not a side-effect-free loop-invariant expression');
        vec:=tvecnode(vn);
      end;


    function distpat_invariant_value_reason(n : tnode; counter : tabstractvarsym) : string;
      { returns '' if n is a provably loop-invariant scalar fit for a fill value:
        a constant, or a plain read of a simple non-aliased local/value-param the
        single-statement body never writes (so it is loop-invariant), and not the
        loop counter.  Otherwise returns a human-readable reason. }
      var
        root : tnode;
      begin
        result:='';
        if not assigned(n) then
          exit('fill value is missing');
        if ([nf_write,nf_modify]*n.flags)<>[] then
          exit('fill value has side effects');
        root:=rangeelim_skip_typeconv(n);
        if not assigned(root) then
          exit('fill value is not a constant or a simple loop-invariant variable');
        if root.nodetype in [ordconstn,realconstn,niln,pointerconstn] then
          exit('');
        if root.nodetype=loadn then
          begin
            if not assigned(rangeelim_simple_var(root)) then
              exit('fill value is not a simple non-aliased local/parameter (a global, address-taken or volatile value is not proven loop-invariant)');
            if tloadnode(root).symtableentry=tsym(counter) then
              exit('fill value is the loop counter');
            exit('');
          end;
        exit('fill value is not a constant or a simple loop-invariant variable');
      end;


    function distpat_const_is_zero(n : tnode) : boolean;
      { true if n is a compile-time constant whose stored bytes are all zero:
        an ordinal 0, nil, or *positive* floating-point zero.  Negative zero is
        rejected (its sign bit is set, so FillChar 0 would not reproduce it). }
      var
        root : tnode;
        d : double;
      begin
        result:=false;
        root:=rangeelim_skip_typeconv(n);
        if not assigned(root) then
          exit;
        case root.nodetype of
          niln:
            result:=true;
          ordconstn:
            result:=tordconstnode(root).value=0;
          pointerconstn:
            result:=tpointerconstnode(root).value=0;
          realconstn:
            begin
              d:=trealconstnode(root).value_real;
              { all-zero bytes <=> +0.0; PInt64 catches the -0.0 sign bit }
              result:=(d=0.0) and (PInt64(@d)^=0);
            end;
          else
            ;
        end;
      end;


    type
      tdistpatcontext = object
        changed : boolean;
        procedure processloop(var n : tnode);
      end;


    procedure tdistpatcontext.processloop(var n : tnode);
      var
        forn : tfornode;
        counter : tabstractvarsym;
        ctype : tdef;
        stmt : tnode;
        assign : tassignmentnode;
        avec, bvec : tvecnode;
        delemdef, selemdef : tdef;
        disdyn, sisdyn : boolean;
        kind : tdistpatkind;
        fillvalue : tnode;
        hascheck : boolean;
        reason : string;
        block : tnode;
        stat : tstatementnode;
        lotemp, hitemp : ttempcreatenode;
        elemcount, bytecount, fillval, dstaddr, srcaddr, guardbody : tnode;
        gstat : tstatementnode;
        elemsize : asizeint;
        fname : string;
        unsigneddef : tdef;

      { Recognizer: returns '' when the loop can be lowered (filling in counter,
        ctype, avec, bvec, kind, fillvalue, delemdef, elemsize), else the reason
        of the first failed check for the -OoLOOPDISTPAT diagnostic. }
      function distpat_reason : string;
        var
          rawsrc : tnode;
        begin
          result:='';

          if lnf_backward in forn.loopflags then
            exit('descending (downto) loop');
          if assigned(forn.loopstep) then
            exit('non-unit loop step');

          counter:=rangeelim_simple_var(forn.left);
          if not assigned(counter) then
            exit('loop counter is not a simple non-aliased variable');
          ctype:=forn.left.resultdef;
          if not assigned(ctype) or (ctype.typ<>orddef) then
            exit('loop counter is not an ordinal type');
          if not is_signed(ctype) or not(ctype.size in [4,8]) then
            exit('loop counter is not a signed 32/64-bit integer');

          if po_inline in current_procinfo.procdef.procoptions then
            exit('enclosing routine is an inline candidate');

          if ([cs_check_range,cs_check_overflow]*current_settings.localswitches)<>[] then
            exit('range/overflow checking is enabled (-Cr/-Co)');

          stmt:=vect_body_single_stmt(forn.t2);
          if not assigned(stmt) then
            exit('loop body is empty or has multiple statements');
          if stmt.nodetype<>assignn then
            exit('loop body is not a single assignment statement');
          assign:=tassignmentnode(stmt);
          if assign.assigntype<>at_normal then
            exit('loop body assignment is not a plain assignment');

          hascheck:=false;
          foreachnodestatic(pm_postprocess,forn.t2,@vect_check_cb,@hascheck);
          if hascheck then
            exit('loop body contains range/overflow-checked code');

          { destination a[i] }
          result:=distpat_elem(assign.left,counter,avec,delemdef,disdyn);
          if result<>'' then
            exit('destination '+result);
          elemsize:=delemdef.size;

          { copy?  a[i] := b[i]  with no source type conversion }
          rawsrc:=assign.right;
          if (rawsrc.nodetype=vecn) and (distpat_elem(rawsrc,counter,bvec,selemdef,sisdyn)='') then
            begin
              if not disdyn or not sisdyn then
                exit('copy source/destination is not a plain dynamic array (static/pointer overlap cannot be excluded)');
              if not equal_defs(delemdef,selemdef) or (selemdef.size<>elemsize) then
                exit('copy source and destination element types differ');
              kind:=dpk_move;
            end
          else
            begin
              { fill: a[i] := <loop-invariant value> }
              bvec:=nil;
              result:=distpat_invariant_value_reason(assign.right,counter);
              if result<>'' then
                exit(result);
              fillvalue:=assign.right;
              if distpat_const_is_zero(fillvalue) then
                kind:=dpk_fillchar_zero
              else if is_fpu(delemdef) then
                exit('non-zero floating-point fill (cannot reinterpret to an integer block primitive)')
              else if not(is_ordinal(delemdef) or is_pointer(delemdef)) then
                exit('non-zero fill of a non-ordinal element type')
              else
                case elemsize of
                  1: kind:=dpk_fillchar;
                  2: kind:=dpk_fillword;
                  4: kind:=dpk_filldword;
                  8: kind:=dpk_fillqword;
                  else
                    exit('element size is not 1, 2, 4 or 8 bytes for a non-zero fill');
                end;
            end;

          { DFA: the counter must not be assigned in the body }
          CalcDefSum(forn.t2);
          if not assigned(forn.t2.optinfo) or not assigned(forn.left.optinfo) then
            exit('data-flow information is unavailable for the loop body');
          if DynSetIn(forn.t2.optinfo^.defsum,forn.left.optinfo^.index) then
            exit('loop counter is modified inside the loop body');
        end;

      begin
        forn:=tfornode(n);

        { pre-initialize the recognizer outputs: a nested function assigning
          parent locals defeats per-procedure DFA, which would otherwise warn
          they are uninitialized on the read paths below (and -Sew turns that
          into an error during an -O4 self-compile). They are always set on the
          reason='' success path. }
        counter:=nil;
        ctype:=nil;
        avec:=nil;
        bvec:=nil;
        delemdef:=nil;
        selemdef:=nil;
        disdyn:=false;
        sisdyn:=false;
        kind:=dpk_fillchar_zero;
        fillvalue:=nil;
        elemsize:=0;

        reason:=distpat_reason;
        if reason<>'' then
          begin
            MessagePos1(forn.fileinfo,cg_n_loop_not_lowered,reason);
            exit;
          end;

        { ---- build the replacement block ---- }
        block:=internalstatements(stat);

        { lo/hi evaluated exactly once, as the original for-loop does }
        lotemp:=ctempcreatenode.create(ctype,ctype.size,tt_persistent,true);
        addstatement(stat,lotemp);
        addstatement(stat,cassignmentnode.create(ctemprefnode.create(lotemp),forn.right.getcopy));
        hitemp:=ctempcreatenode.create(ctype,ctype.size,tt_persistent,true);
        addstatement(stat,hitemp);
        addstatement(stat,cassignmentnode.create(ctemprefnode.create(hitemp),forn.t1.getcopy));

        { destination base address a[lo] }
        dstaddr:=cvecnode.create(avec.left.getcopy,ctemprefnode.create(lotemp));

        { element count n = hi-lo+1, widened to SizeInt so n*sz cannot wrap; a
          fresh copy is built per use so no node is shared between two parents }
        elemcount:=nil; bytecount:=nil;

        guardbody:=internalstatements(gstat);
        case kind of
          dpk_move:
            begin
              srcaddr:=cvecnode.create(bvec.left.getcopy,ctemprefnode.create(lotemp));
              fname:='MOVE';
              bytecount:=caddnode.create(muln,
                ctypeconvnode.create_internal(
                  caddnode.create(addn,
                    caddnode.create(subn,ctemprefnode.create(hitemp),ctemprefnode.create(lotemp)),
                    cordconstnode.create(1,ctype,false)),
                  sizesinttype),
                cordconstnode.create(elemsize,sizesinttype,false));
              { Move(source, dest, count) : outer para is count }
              addstatement(gstat,ccallnode.createintern('MOVE',
                ccallparanode.create(bytecount,
                  ccallparanode.create(dstaddr,
                    ccallparanode.create(srcaddr,nil)))));
            end;
          dpk_fillchar_zero:
            begin
              fname:='FILLCHAR';
              bytecount:=caddnode.create(muln,
                ctypeconvnode.create_internal(
                  caddnode.create(addn,
                    caddnode.create(subn,ctemprefnode.create(hitemp),ctemprefnode.create(lotemp)),
                    cordconstnode.create(1,ctype,false)),
                  sizesinttype),
                cordconstnode.create(elemsize,sizesinttype,false));
              { FillChar(x, count, value) : outer para is value }
              addstatement(gstat,ccallnode.createintern('FILLCHAR',
                ccallparanode.create(cordconstnode.create(0,u8inttype,false),
                  ccallparanode.create(bytecount,
                    ccallparanode.create(dstaddr,nil)))));
            end;
          dpk_fillchar,dpk_fillword,dpk_filldword,dpk_fillqword:
            begin
              case kind of
                dpk_fillchar:  begin fname:='FILLCHAR';  unsigneddef:=u8inttype;  end;
                dpk_fillword:  begin fname:='FILLWORD';  unsigneddef:=u16inttype; end;
                dpk_filldword: begin fname:='FILLDWORD'; unsigneddef:=u32inttype; end;
                else           begin fname:='FILLQWORD'; unsigneddef:=u64inttype; end;
              end;
              { value = unsigned-of-elemsize(elementtype(v)); the double
                create_internal first pins the exact bytes the scalar store would
                write, then reinterprets them to the block primitive's width }
              fillval:=ctypeconvnode.create_internal(
                ctypeconvnode.create_internal(fillvalue.getcopy,delemdef),
                unsigneddef);
              { sized fills count elements, not bytes }
              elemcount:=ctypeconvnode.create_internal(
                caddnode.create(addn,
                  caddnode.create(subn,ctemprefnode.create(hitemp),ctemprefnode.create(lotemp)),
                  cordconstnode.create(1,ctype,false)),
                sizesinttype);
              addstatement(gstat,ccallnode.createintern(fname,
                ccallparanode.create(fillval,
                  ccallparanode.create(elemcount,
                    ccallparanode.create(dstaddr,nil)))));
            end;
        end;

        { the for-loop counter is language-undefined after the loop, but leave it
          at the value a normal ascending for-loop leaves -- its last taken value
          hi -- so later reads are unsurprised and DFA sees it defined }
        addstatement(gstat,cassignmentnode.create(
          cloadnode.create(tsym(counter),counter.owner),
          ctemprefnode.create(hitemp)));

        { the loop runs only for lo <= hi; a for-loop is a no-op otherwise, and
          the byte count must not be built from a negative difference }
        addstatement(stat,cifnode.create_internal(
          caddnode.create(lten,ctemprefnode.create(lotemp),ctemprefnode.create(hitemp)),
          guardbody,nil));

        addstatement(stat,ctempdeletenode.create(lotemp));
        addstatement(stat,ctempdeletenode.create(hitemp));

        do_firstpass(block);
        MessagePos1(forn.fileinfo,cg_n_loop_idiom_lowered,fname);
        forn.free;
        n:=block;
        changed:=true;
      end;


    function distpat_processloop_cb(var n : tnode; arg : pointer) : foreachnoderesult;
      begin
        result:=fen_false;
        if n.nodetype=forn then
          begin
            tdistpatcontext(arg^).processloop(n);
            result:=fen_norecurse_false;
          end;
      end;


    function OptimizeLoopDistPat(node : tnode) : boolean;
      var
        ctx : tdistpatcontext;
      begin
        Result:=false;
        if not(pi_dfaavailable in current_procinfo.flags) then
          exit;
        ctx.changed:=false;
        { postorder so nested (inner) loops are considered before their parents }
        foreachnodestatic(pm_postprocess,node,@distpat_processloop_cb,@ctx);
        Result:=ctx.changed;
      end;


{*****************************************************************************
                                 Loop peeling
*****************************************************************************}

    { A node-tree port of gcc's -fpeel-loops (its full-peel case): a counted
      for-loop whose trip count is a small compile-time constant is replaced by
      that many straight-line copies of the body, with the induction variable
      folded to its per-iteration constant.  This deletes the counter, the loop
      compare and the back-branch, and exposes every iteration to the ordinary
      constant folder / propagator (a[i] index nodes become a[k] with k const).

      The stock loop unroller (unroll_loop, run in tfornode.pass_1) already fully
      unrolls a constant-count loop when its cost heuristic says the whole loop
      fits in its unroll budget (getridoffor).  This pass is the deliberate,
      -O4-only complement for the loops that heuristic declines: small fixed
      trip counts (<= 8) whose body is a little too large for the generic
      unroller but still well inside a bounded peel budget -- exactly the short
      fixed-extent kernels (3x3 convolution taps, per-channel Depth in 1/3/4)
      that sit inside hot outer loops where the loop control rivals the body.

      Soundness gates (a wrong peel is a miscompile):
        * ascending or descending, but the step must be unit (loopstep unset);
        * both bounds are ordinal constants, so the exact trip count is known;
        * the counter is a simple non-aliased, non-address-taken, non-volatile
          local / value parameter of an ordinal type, and DFA proves it is never
          assigned in the body (so replacing its loads by a constant is sound and
          replaceloadnodes never meets a write/modify/address-taken use);
        * the body has no break / continue / goto / label / exit / raise, so
          duplicating it cannot change control flow or which copy runs;
        * not TP/Mac mode (there the loop var may be assigned) and not an inline
          candidate or -Os build (peeling trades size for speed).

      A statically empty loop (trip <= 0) is left untouched: a Pascal for-loop
      that never runs leaves its counter unmodified, and declining reproduces
      that exactly.  When the loop does run, the counter is left holding its last
      taken value (t1, the "to" bound) just as a normal for-loop does. }

    const
      looppeel_max_trip   = 8;    { largest constant trip count we fully peel }
      looppeel_body_max   = 40;   { per-body weighted-node cap }
      looppeel_total_max  = 160;  { trip*body weighted-node growth cap }

    type
      tlooppeelcontext = object
        changed : boolean;
        procedure processloop(var n : tnode);
      end;


    procedure tlooppeelcontext.processloop(var n : tnode);
      var
        forn : tfornode;
        counter : tabstractvarsym;
        ctype : tdef;
        reason : string;
        backward : boolean;
        lo, hi, trip, curval, k : tconstexprint;
        bodycost : dword;
        block : tnode;
        stat : tstatementnode;
        replaceinfo : treplaceinfo;
        bodycopy : tnode;

      { Recognizer: '' when the loop can be peeled (filling counter, ctype,
        backward, lo, hi, trip), else the reason of the first failed check for
        the -OoLOOPPEEL diagnostic. }
      function looppeel_reason : string;
        begin
          result:='';

          if cs_opt_size in current_settings.optimizerswitches then
            exit('optimizing for size (-Os)');
          if po_inline in current_procinfo.procdef.procoptions then
            exit('enclosing routine is an inline candidate');
          if [m_tp7,m_mac]*current_settings.modeswitches<>[] then
            exit('TP/Mac mode allows assignment to the loop variable');

          if assigned(forn.loopstep) then
            exit('non-unit loop step');

          counter:=rangeelim_simple_var(forn.left);
          if not assigned(counter) then
            exit('loop counter is not a simple non-aliased variable');
          ctype:=forn.left.resultdef;
          if not assigned(ctype) or (ctype.typ<>orddef) then
            exit('loop counter is not an ordinal type');

          if (forn.right.nodetype<>ordconstn) or (forn.t1.nodetype<>ordconstn) then
            exit('loop bounds are not both compile-time constants');

          backward:=lnf_backward in forn.loopflags;
          lo:=tordconstnode(forn.right).value;
          hi:=tordconstnode(forn.t1).value;
          if backward then
            trip:=lo-hi+1
          else
            trip:=hi-lo+1;

          if trip<=0 then
            exit('constant trip count is zero (statically dead loop)');
          if trip>looppeel_max_trip then
            exit('constant trip count exceeds the peel limit');

          if foreachnodestatic(forn.t2,@checkcontrollflowstatements,nil) then
            exit('loop body contains break/continue/goto/label/exit/raise');

          bodycost:=node_count_weighted(forn.t2,looppeel_body_max+1);
          if bodycost>looppeel_body_max then
            exit('loop body is too large to peel');
          if qword(bodycost)*qword(trip.svalue)>looppeel_total_max then
            exit('peeled body would exceed the code-size budget');

          { DFA: the counter must not be assigned in the body }
          CalcDefSum(forn.t2);
          if not assigned(forn.t2.optinfo) or not assigned(forn.left.optinfo) then
            exit('data-flow information is unavailable for the loop body');
          if DynSetIn(forn.t2.optinfo^.defsum,forn.left.optinfo^.index) then
            exit('loop counter is modified inside the loop body');
        end;

      begin
        forn:=tfornode(n);

        { pre-initialize the recognizer outputs (see the matching note in
          tdistpatcontext.processloop): a nested function assigning parent
          locals defeats per-procedure DFA, which would otherwise warn they are
          uninitialized on the read paths below. }
        counter:=nil;
        ctype:=nil;
        backward:=false;
        lo:=0; hi:=0; trip:=0;

        reason:=looppeel_reason;
        if reason<>'' then
          begin
            MessagePos1(forn.fileinfo,cg_n_loop_not_peeled,reason);
            exit;
          end;

        { ---- build the straight-line replacement ---- }
        block:=internalstatements(stat);

        { first taken value is the "from" bound (forn.right) in both directions }
        curval:=lo;
        k:=1;
        while k<=trip do
          begin
            bodycopy:=forn.t2.getcopy;
            replaceinfo.node:=forn.left;
            replaceinfo.value:=curval;
            foreachnodestatic(bodycopy,@replaceloadnodes,@replaceinfo);
            addstatement(stat,bodycopy);
            if backward then
              curval:=curval-1
            else
              curval:=curval+1;
            k:=k+1;
          end;

        { leave the counter with the value a normal for-loop leaves after it ran:
          its last taken value, which for both directions is the "to" bound hi
          (t1). Keeps DFA seeing the counter defined and later reads unsurprised. }
        addstatement(stat,cassignmentnode.create(
          cloadnode.create(tsym(counter),counter.owner),
          cordconstnode.create(hi,ctype,false)));

        do_firstpass(block);
        MessagePos1(forn.fileinfo,cg_n_loop_peeled,tostr(trip.svalue));
        forn.free;
        n:=block;
        changed:=true;
      end;


    function looppeel_processloop_cb(var n : tnode; arg : pointer) : foreachnoderesult;
      begin
        result:=fen_false;
        if n.nodetype=forn then
          begin
            tlooppeelcontext(arg^).processloop(n);
            result:=fen_norecurse_false;
          end;
      end;


    function OptimizeLoopPeel(node : tnode) : boolean;
      var
        ctx : tlooppeelcontext;
      begin
        Result:=false;
        if not(pi_dfaavailable in current_procinfo.flags) then
          exit;
        ctx.changed:=false;
        { postorder so an inner loop is peeled before its enclosing loop's body
          is duplicated (the inner peel shrinks/enlarges the copies consistently) }
        foreachnodestatic(pm_postprocess,node,@looppeel_processloop_cb,@ctx);
        Result:=ctx.changed;
      end;


{*****************************************************************************
                                Loop splitting
*****************************************************************************}

    { A node-tree port of gcc's -fsplit-loops.  When the whole body of a counted
      for-loop is a single conditional whose predicate compares the induction
      variable against a loop-invariant bound m -- if i < m then A else B and its
      relatives -- the truth value flips exactly once as i sweeps the range, so
      the iteration space splits cleanly at the crossover:

          for i := lo to hi do          -->   c := clamp(crossover, lo, hi+1);
            if i < m then A else B             for i := lo    to c-1 do A;
                                               for i := c     to hi  do B;

      Both resulting bodies are branch-free (the per-iteration compare is gone),
      the interior loop -- the overwhelming majority of iterations, e.g. the
      non-border rows of a padded convolution -- becomes a uniform kernel a later
      pass can vectorize, and only the short border loop keeps the boundary work.

      This is distinct from loop unswitching (whose condition is invariant in
      *both* operands and never changes across iterations): here the IV side
      *crosses* the bound exactly once, so unswitching cannot fire.

      Soundness (a wrong split is a miscompile):
        * ascending unit-step loop, both bounds present; the counter is a simple
          non-aliased signed 32-bit local / value param, DFA-proven unmodified in
          the body (32-bit so the widened int64 crossover math -- m+-1, hi+1 --
          cannot overflow);
        * the body is exactly one if-statement whose condition is i <rel> m with
          rel in < <= > >= (monotone in i; = and <> are rejected) and m either an
          ordinal constant or a simple non-aliased ordinal (<=32-bit) local /
          value param DFA-proven unmodified in the body (so evaluating it once
          before the loops equals evaluating it each iteration, and it cannot
          trap);
        * neither branch contains break/continue/goto/label/exit/raise: a break
          in one sub-loop would leave the other sub-loop still running, so such
          shapes are declined;
        * not TP/Mac mode, not an inline candidate, not -Os, and range/overflow
          checking off (kept conservative; the branch bodies keep their own
          checks in the copies).

      The crossover is clamped into [lo, hi+1] in a widened int64 domain and each
      sub-loop is emitted under an `if lo<=c-1` / `if c<=hi` guard, which both
      skips the statically-empty sub-range and keeps the narrowing of c back to
      the 32-bit counter type in range.  Because the two loops tile [lo, hi]
      contiguously, the counter is left with exactly the value a single for-loop
      would leave (hi when the loop ran, unchanged when it did not). }

    const
      loopsplit_body_max = 200;   { weighted-node cap on the body we restructure }

    type
      tloopsplitcontext = object
        changed : boolean;
        procedure processloop(var n : tnode);
      end;


    { swap a relational operator for the case  m <op> i  ==  i <swap> m }
    function loopsplit_swap_relop(o : tnodetype) : tnodetype;
      begin
        case o of
          ltn:  result:=gtn;
          lten: result:=gten;
          gtn:  result:=ltn;
          gten: result:=lten;
          else  result:=o;
        end;
      end;


    { True if m is a valid loop-invariant bound for the split: an ordinal
      constant, or a simple non-aliased ordinal (<=32-bit) local/value-param load
      that is neither the counter nor assigned anywhere in the loop body. }
    function loopsplit_invariant_bound(m : tnode; counter : tabstractvarsym; body : tnode) : boolean;
      var
        root : tnode;
        sym : tabstractvarsym;
      begin
        result:=false;
        root:=rangeelim_skip_typeconv(m);
        if not assigned(root) then
          exit;
        if root.nodetype=ordconstn then
          exit(true);
        sym:=rangeelim_simple_var(root);
        if not assigned(sym) or (sym=counter) then
          exit;
        if not assigned(root.resultdef) or not is_ordinal(root.resultdef) or (root.resultdef.size>4) then
          exit;
        { DFA: m must not be assigned in the loop body }
        if not assigned(body.optinfo) or not assigned(root.optinfo) then
          exit;
        if DynSetIn(body.optinfo^.defsum,root.optinfo^.index) then
          exit;
        result:=true;
      end;


    procedure tloopsplitcontext.processloop(var n : tnode);
      var
        forn : tfornode;
        counter : tabstractvarsym;
        ctype : tdef;
        reason : string;
        stmt : tnode;
        theif : tifnode;
        cond : tnode;
        op : tnodetype;
        mexpr : tnode;
        lowthen : boolean;   { low sub-range runs the then-branch }
        crossplus : longint; { crossover = m + crossplus }
        thenb, elseb, lowbody, highbody : tnode;
        block : tnode;
        stat : tstatementnode;
        lotemp, hitemp : ttempcreatenode;
        crosstemp : ttempcreatenode;
        loop1, loop2 : tnode;

      { Recognizer: '' when the loop can be split (filling counter, ctype, theif,
        op, mexpr, lowthen, crossplus), else the first failed check's reason. }
      function loopsplit_reason : string;
        var
          l, r : tnode;
        begin
          result:='';

          if cs_opt_size in current_settings.optimizerswitches then
            exit('optimizing for size (-Os)');
          if po_inline in current_procinfo.procdef.procoptions then
            exit('enclosing routine is an inline candidate');
          if [m_tp7,m_mac]*current_settings.modeswitches<>[] then
            exit('TP/Mac mode allows assignment to the loop variable');
          if ([cs_check_range,cs_check_overflow]*current_settings.localswitches)<>[] then
            exit('range/overflow checking is enabled (-Cr/-Co)');

          if lnf_backward in forn.loopflags then
            exit('descending (downto) loop');
          if assigned(forn.loopstep) then
            exit('non-unit loop step');

          counter:=rangeelim_simple_var(forn.left);
          if not assigned(counter) then
            exit('loop counter is not a simple non-aliased variable');
          ctype:=forn.left.resultdef;
          if not assigned(ctype) or (ctype.typ<>orddef) then
            exit('loop counter is not an ordinal type');
          if not is_signed(ctype) or (ctype.size<>4) then
            exit('loop counter is not a signed 32-bit integer');

          stmt:=vect_body_single_stmt(forn.t2);
          if not assigned(stmt) then
            exit('loop body is empty or has multiple statements');
          if stmt.nodetype<>ifn then
            exit('loop body is not a single if-statement');
          theif:=tifnode(stmt);
          if not assigned(theif.right) and not assigned(theif.t1) then
            exit('if-statement has no branches');

          if foreachnodestatic(forn.t2,@checkcontrollflowstatements,nil) then
            exit('loop body contains break/continue/goto/label/exit/raise');

          { the condition must be  i <rel> m  or  m <rel> i, rel monotone in i }
          cond:=theif.left;
          if not assigned(cond) or not(cond.nodetype in [ltn,lten,gtn,gten]) then
            exit('if condition is not a monotone <,<=,>,>= comparison');
          if ([nf_write,nf_modify]*cond.flags)<>[] then
            exit('if condition has side effects');
          l:=taddnode(cond).left;
          r:=taddnode(cond).right;

          { data-flow for the invariance test below }
          CalcDefSum(forn.t2);
          if not assigned(forn.t2.optinfo) or not assigned(forn.left.optinfo) then
            exit('data-flow information is unavailable for the loop body');
          if DynSetIn(forn.t2.optinfo^.defsum,forn.left.optinfo^.index) then
            exit('loop counter is modified inside the loop body');

          if (rangeelim_simple_var(rangeelim_skip_typeconv(l))=counter) and
             loopsplit_invariant_bound(r,counter,forn.t2) then
            begin
              op:=cond.nodetype;   { i <op> m }
              mexpr:=r;
            end
          else if (rangeelim_simple_var(rangeelim_skip_typeconv(r))=counter) and
                  loopsplit_invariant_bound(l,counter,forn.t2) then
            begin
              op:=loopsplit_swap_relop(cond.nodetype);   { m <op0> i  ==  i <swap> m }
              mexpr:=l;
            end
          else
            exit('condition is not induction-variable vs loop-invariant bound');

          { crossover = m (+1 for <= / >) ; low sub-range runs the then-branch
            for the "true for small i" relations (< , <=) }
          case op of
            ltn:  begin lowthen:=true;  crossplus:=0; end;
            lten: begin lowthen:=true;  crossplus:=1; end;
            gtn:  begin lowthen:=false; crossplus:=1; end;
            gten: begin lowthen:=false; crossplus:=0; end;
            else
              exit('condition is not a monotone comparison');
          end;

          if node_count_weighted(forn.t2,loopsplit_body_max+1)>loopsplit_body_max then
            exit('loop body is too large to split');
        end;

      { widen a counter-domain expression to the signed pointer int the crossover
        arithmetic runs in }
      function widen(nn : tnode) : tnode;
        begin
          result:=ctypeconvnode.create_internal(nn,sizesinttype);
        end;

      begin
        forn:=tfornode(n);

        { pre-initialize recognizer outputs (nested-function DFA, see the note in
          tdistpatcontext.processloop) }
        counter:=nil;
        ctype:=nil;
        theif:=nil;
        op:=ltn;
        mexpr:=nil;
        lowthen:=true;
        crossplus:=0;

        reason:=loopsplit_reason;
        if reason<>'' then
          begin
            MessagePos1(forn.fileinfo,cg_n_loop_not_split,reason);
            exit;
          end;

        { steal the two branches; the emptied if is freed with the for-node }
        thenb:=theif.right; theif.right:=nil;
        elseb:=theif.t1;    theif.t1:=nil;
        if lowthen then
          begin lowbody:=thenb; highbody:=elseb; end
        else
          begin lowbody:=elseb; highbody:=thenb; end;
        if not assigned(lowbody)  then lowbody:=cnothingnode.create;
        if not assigned(highbody) then highbody:=cnothingnode.create;

        { ---- build the replacement block ---- }
        block:=internalstatements(stat);

        { lo / hi evaluated exactly once, as the original for-loop does }
        lotemp:=ctempcreatenode.create(ctype,ctype.size,tt_persistent,true);
        addstatement(stat,lotemp);
        addstatement(stat,cassignmentnode.create(ctemprefnode.create(lotemp),forn.right.getcopy));
        hitemp:=ctempcreatenode.create(ctype,ctype.size,tt_persistent,true);
        addstatement(stat,hitemp);
        addstatement(stat,cassignmentnode.create(ctemprefnode.create(hitemp),forn.t1.getcopy));

        { crossover in a widened int64 domain: c := m [+ crossplus] }
        crosstemp:=ctempcreatenode.create(sizesinttype,sizesinttype.size,tt_persistent,true);
        addstatement(stat,crosstemp);
        addstatement(stat,cassignmentnode.create(ctemprefnode.create(crosstemp),
          caddnode.create(addn,widen(mexpr.getcopy),
            cordconstnode.create(crossplus,sizesinttype,false))));

        { clamp c into [lo, hi+1] so both narrowings below stay in range }
        addstatement(stat,cifnode.create_internal(
          caddnode.create(ltn,ctemprefnode.create(crosstemp),widen(ctemprefnode.create(lotemp))),
          cassignmentnode.create(ctemprefnode.create(crosstemp),widen(ctemprefnode.create(lotemp))),
          nil));
        addstatement(stat,cifnode.create_internal(
          caddnode.create(gtn,ctemprefnode.create(crosstemp),
            caddnode.create(addn,widen(ctemprefnode.create(hitemp)),cordconstnode.create(1,sizesinttype,false))),
          cassignmentnode.create(ctemprefnode.create(crosstemp),
            caddnode.create(addn,widen(ctemprefnode.create(hitemp)),cordconstnode.create(1,sizesinttype,false))),
          nil));

        { low loop:  if lo <= c-1 then for i := lo to (c-1) do lowbody }
        loop1:=cfornode.create(forn.left.getcopy,
          ctemprefnode.create(lotemp),
          ctypeconvnode.create_internal(
            caddnode.create(subn,ctemprefnode.create(crosstemp),cordconstnode.create(1,sizesinttype,false)),
            ctype),
          lowbody,false);
        addstatement(stat,cifnode.create_internal(
          caddnode.create(lten,widen(ctemprefnode.create(lotemp)),
            caddnode.create(subn,ctemprefnode.create(crosstemp),cordconstnode.create(1,sizesinttype,false))),
          loop1,nil));

        { high loop:  if c <= hi then for i := c to hi do highbody }
        loop2:=cfornode.create(forn.left.getcopy,
          ctypeconvnode.create_internal(ctemprefnode.create(crosstemp),ctype),
          ctemprefnode.create(hitemp),
          highbody,false);
        addstatement(stat,cifnode.create_internal(
          caddnode.create(lten,ctemprefnode.create(crosstemp),widen(ctemprefnode.create(hitemp))),
          loop2,nil));

        addstatement(stat,ctempdeletenode.create(lotemp));
        addstatement(stat,ctempdeletenode.create(hitemp));
        addstatement(stat,ctempdeletenode.create(crosstemp));

        do_firstpass(block);
        MessagePos1(forn.fileinfo,cg_n_loop_split,'');
        forn.free;
        n:=block;
        changed:=true;
      end;


    function loopsplit_processloop_cb(var n : tnode; arg : pointer) : foreachnoderesult;
      begin
        result:=fen_false;
        if n.nodetype=forn then
          begin
            tloopsplitcontext(arg^).processloop(n);
            result:=fen_norecurse_false;
          end;
      end;


    function OptimizeLoopSplit(node : tnode) : boolean;
      var
        ctx : tloopsplitcontext;
      begin
        Result:=false;
        if not(pi_dfaavailable in current_procinfo.flags) then
          exit;
        ctx.changed:=false;
        { postorder so an inner loop is split before its enclosing loop is }
        foreachnodestatic(pm_postprocess,node,@loopsplit_processloop_cb,@ctx);
        Result:=ctx.changed;
      end;


{*****************************************************************************
                                 Loop fusion
*****************************************************************************}

    { A node-tree port of gcc/LLVM loop fusion (the inverse of the loop-
      distribution above).  Two *adjacent* counted for-loops over the identical
      iteration space are merged into one loop whose body is the concatenation of
      the two original bodies:

        for i := lo to hi do A(i);          -->   for i := lo to hi do
        for i := lo to hi do B(i);                  begin A(i); B(i) end;

      so an intermediate result A writes to memory and B immediately re-reads (a
      bias/scale add followed by an activation, a gradient accumulate followed by
      a weight update -- the consecutive element-wise passes neural-api runs over
      one TNNetVolume) stays in registers / cache for one pass instead of being
      streamed out by the first loop and reloaded from DRAM by the second.  The
      fused element-wise loop is also a clean vectorizer candidate, which is why
      the pass runs *before* OptimizeVectorize at the psub call site.

      DEPENDENCE SAFETY (a wrong fusion is a miscompile, so the recognizer is
      strict; anything not matched compiles exactly as before).  Fusion is legal
      iff no iteration i of loop 2 needs a value that loop 1 has not yet produced
      for that same index i (and, symmetrically, loop 1 must not read a location
      loop 2 will only overwrite later).  We guarantee this with one blunt,
      provably sufficient rule instead of a general dependence test:

        * EVERY array-element reference in both bodies -- read or write -- is
          indexed by *exactly* the loop counter (unit stride, no a[i-1]/a[i+1]
          offset).  Then everything either body touches at "time i" lives at
          array index i, so after the reorder body1(i) still runs before body2(i)
          and no iteration ever reaches an element another iteration owns.  This
          holds regardless of aliasing: two dynamic arrays can only fully alias at
          offset 0 or be disjoint (a shifted overlap is impossible -- the same
          fact LOOPDISTPAT relied on), and a full alias with identical [i]
          indexing is still element-wise safe; static arrays / fields likewise,
          because the index is the same i on both sides.
        * The ONLY writes allowed are to such a[counter] element (the write flag
          sits on the vecn).  A scalar / field / pointer write (write flag on a
          loadn / subscriptn / derefn) is declined outright -- that is exactly the
          channel by which a value could be carried across the loop boundary
          (a[i]:=s in loop 2 after s:=... in loop 1, a reduction into the same
          scalar in both loops, ...).  Because no scalar or field is ever written
          by either body, every scalar/field a body reads (and every variable the
          shared bounds mention) is loop-invariant across the whole fused region,
          so reordering cannot change its value.
        * No calls (side effects / unprovable aliasing), no pointer dereferences
          (unprovable aliasing), no inline intrinsics (inc/dec/setlength/... can
          write; declined wholesale), no nested loops (their indices are not the
          fused counter), and no break/continue/goto/label/exit/raise (control
          must not enter a fused body mid-stream).  Only plain (:=) assignments.
        * -Cr/-Co checked code is declined: fusion reorders the per-element
          bounds/overflow checks, so a check that would fire first in loop 1 could
          be preceded by one from loop 2.
        * Both loops are ascending, unit step, and their lo/hi bounds are
          structurally equal (tnode.isequal) and free of calls/derefs, so -- given
          no body writes any scalar and nothing runs between the two loops -- the
          value each bound evaluates to at loop 1's entry equals its value at loop
          2's entry, i.e. the two iteration spaces are provably identical.
        * Counters may be the same variable or two different simple non-aliased
          locals of the same ordinal type; in the latter case loop 2's body is
          rewritten to use loop 1's counter and, to match a stand-alone for-loop's
          post-value, loop 2's counter is set to hi after the fused loop, guarded
          by  if lo<=hi  (a for-loop that ran zero times leaves its counter
          untouched).  The fused loop itself leaves loop 1's counter at hi exactly
          as the original first loop did.
        * The enclosing routine is not an inline candidate and has no labels
          (checked at the psub call site, like the sibling loop passes). }

    type
      tfusebodyinfo = record
        counter : tabstractvarsym;
        badreason : string;
      end;
      pfusebodyinfo = ^tfusebodyinfo;


    function fuse_body_check_cb(var n : tnode; arg : pointer) : foreachnoderesult;
      { rejects any body construct that would make the reorder unsound: a call,
        a pointer deref, an inline intrinsic, a nested loop, control flow, a
        non-plain assignment, a scalar/field/pointer write, or an array-element
        access whose index is not exactly the loop counter }
      var
        pc : pfusebodyinfo;
        idx, lhs : tnode;
      begin
        result:=fen_false;
        pc:=pfusebodyinfo(arg);
        case n.nodetype of
          calln:
            begin
              pc^.badreason:='body contains a call';
              exit(fen_norecurse_true);
            end;
          inlinen:
            { only a small whitelist of pure, side-effect-free, single-argument
              arithmetic intrinsics is allowed -- they read their operand (an
              a[counter] element or an invariant) and return a value with no
              memory write and no cross-element access, so they cannot introduce a
              dependence.  Min/Max in particular is what FPC's if-conversion turns
              a  if a[i]<0 then a[i]:=0  ReLU activation into (in_max_*), the very
              activation-after-scale shape this pass targets.  Any other intrinsic
              (inc/dec, setlength, i/o, new, ...) may write or have side effects
              and is declined. }
            if not (tinlinenode(n).inlinenumber in
                 [in_abs_long,in_abs_real,in_sqr_real,in_sqrt_real,
                  in_min_single,in_max_single,in_min_double,in_max_double,
                  in_min_dword,in_max_dword,in_min_longint,in_max_longint,
                  in_min_qword,in_max_qword,in_min_int64,in_max_int64,
                  in_min_quad,in_max_quad]) then
              begin
                pc^.badreason:='body contains a non-pure inline intrinsic';
                exit(fen_norecurse_true);
              end;
          derefn,addrn:
            begin
              pc^.badreason:='body dereferences or takes the address of a pointer (aliasing cannot be proven)';
              exit(fen_norecurse_true);
            end;
          forn,whilerepeatn:
            begin
              pc^.badreason:='body contains a nested loop';
              exit(fen_norecurse_true);
            end;
          breakn,continuen,goton,labeln,exitn,raisen:
            begin
              pc^.badreason:='body contains break/continue/goto/label/exit/raise';
              exit(fen_norecurse_true);
            end;
          assignn:
            begin
              if tassignmentnode(n).assigntype<>at_normal then
                begin
                  pc^.badreason:='body has a non-plain (compound) assignment';
                  exit(fen_norecurse_true);
                end;
              { the ONLY writes allowed are to an array element a[counter]: its
                lhs is a vecn (whose [counter] index is checked by the vecn case
                below).  Any other assignment target -- a plain scalar (loadn), a
                record/object field (subscriptn) or a pointer target (derefn) --
                is a channel that could carry a value across the loop boundary, so
                it is declined.  Note we must test the assignment *target*, not a
                write/modify flag: writing a[i] marks the array-base load/subscript
                nf_modify too (e.g. a dynamic-array field Self.FData[i]:=x), and
                that base is a safe element access, not a scalar write. }
              lhs:=rangeelim_skip_typeconv(tassignmentnode(n).left);
              if not assigned(lhs) or (lhs.nodetype<>vecn) then
                begin
                  pc^.badreason:='body writes a scalar, field or pointer target (only a[counter] element stores are allowed)';
                  exit(fen_norecurse_true);
                end;
            end;
          vecn:
            begin
              idx:=rangeelim_skip_typeconv(tvecnode(n).right);
              if not assigned(idx) or (idx.nodetype<>loadn) or
                 (tloadnode(idx).symtableentry<>tsym(pc^.counter)) then
                begin
                  pc^.badreason:='array index is not exactly the loop counter (non-unit stride or offset)';
                  exit(fen_norecurse_true);
                end;
            end;
          else
            ;
        end;
      end;


    function fuse_loop_ok(forn : tfornode; out counter : tabstractvarsym;
                          out ctype : tdef) : string;
      { per-loop gate shared by both fusion candidates: '' when forn is an
        ascending unit-step counted loop over a simple non-aliased ordinal
        counter whose body is safe to reorder element-wise, else the reason }
      var
        bi : tfusebodyinfo;
      begin
        result:='';
        counter:=nil;
        ctype:=nil;

        if lnf_backward in forn.loopflags then
          exit('descending (downto) loop');
        if assigned(forn.loopstep) then
          exit('non-unit loop step');

        counter:=rangeelim_simple_var(forn.left);
        if not assigned(counter) then
          exit('loop counter is not a simple non-aliased variable');
        ctype:=forn.left.resultdef;
        if not assigned(ctype) or (ctype.typ<>orddef) then
          exit('loop counter is not an ordinal type');

        if ([cs_check_range,cs_check_overflow]*current_settings.localswitches)<>[] then
          exit('range/overflow checking is enabled (-Cr/-Co)');

        if not assigned(forn.t2) then
          exit('loop body is empty');

        bi.counter:=counter;
        bi.badreason:='';
        foreachnodestatic(forn.t2,@fuse_body_check_cb,@bi);
        if bi.badreason<>'' then
          exit(bi.badreason);

        { DFA: the counter must not be assigned in the body }
        CalcDefSum(forn.t2);
        if not assigned(forn.t2.optinfo) or not assigned(forn.left.optinfo) then
          exit('data-flow information is unavailable for the loop body');
        if DynSetIn(forn.t2.optinfo^.defsum,forn.left.optinfo^.index) then
          exit('loop counter is modified inside the loop body');
      end;


    function fuse_bound_impure_cb(var n : tnode; arg : pointer) : foreachnoderesult;
      { flags a call or pointer deref anywhere in a bound expression }
      begin
        if n.nodetype in [calln,derefn] then
          result:=fen_norecurse_true
        else
          result:=fen_false;
      end;


    function fuse_bound_pure(n : tnode) : boolean;
      { true when the bound expression contains no call and no pointer deref, so
        it is side-effect free and safe to re-evaluate for the counter fixup }
      begin
        result:=not foreachnodestatic(n,@fuse_bound_impure_cb,nil);
      end;


    type
      tloopfusecontext = object
        changed : boolean;
        procedure processfuse(var n : tnode);
      end;


    function fuse_next_meaningful(s1 : tstatementnode) : tstatementnode;
      { the first following statement in the list that is not an empty
        (nothingn) placeholder, or nil -- so trailing/interleaved nothings do not
        break adjacency but a real intervening statement does }
      var
        s : tnode;
      begin
        result:=nil;
        s:=s1.right;
        while assigned(s) and (s.nodetype=statementn) do
          begin
            if assigned(tstatementnode(s).left) and
               (tstatementnode(s).left.nodetype<>nothingn) then
              begin
                result:=tstatementnode(s);
                exit;
              end;
            s:=tstatementnode(s).right;
          end;
      end;


    procedure tloopfusecontext.processfuse(var n : tnode);
      var
        s1, s2 : tstatementnode;
        forn1, forn2 : tfornode;
        c1, c2 : tabstractvarsym;
        ct1, ct2 : tdef;
        reason : string;
        body1copy, body2copy : tnode;
        newbody, fusedfor : tnode;
        bstat : tstatementnode;
        fusedany, firstpair : boolean;

      function fuse_reason : string;
        begin
          result:='';
          { forn1 is validated only on the first pair; on later greedy iterations
            it is the loop we just built (whose counter c1/ct1 we still hold and
            whose body -- concatenated from already-checked, counter-preserving
            bodies -- is safe), and re-running fuse_loop_ok on it would fail merely
            because the synthesized node has no per-procedure DFA info yet }
          if firstpair then
            begin
              reason:=fuse_loop_ok(forn1,c1,ct1);
              if reason<>'' then
                exit('first '+reason);
            end;
          reason:=fuse_loop_ok(forn2,c2,ct2);
          if reason<>'' then
            exit('second '+reason);
          { same iteration space: structurally equal bounds, pure so the value is
            stable between the two loop entries (no body writes a scalar) }
          if not forn1.right.isequal(forn2.right) then
            exit('the two loops have different lower bounds');
          if not forn1.t1.isequal(forn2.t1) then
            exit('the two loops have different upper bounds');
          if not fuse_bound_pure(forn1.right) or not fuse_bound_pure(forn1.t1) then
            exit('loop bounds are not side-effect free');
          { two distinct counters must share the ordinal type so the rewrite of
            loop 2 onto loop 1's counter is type-correct }
          if (c1<>c2) and not equal_defs(ct1,ct2) then
            exit('the two loops use counters of different types');
        end;

      begin
        if n.nodetype<>statementn then
          exit;
        s1:=tstatementnode(n);
        if not assigned(s1.left) or (s1.left.nodetype<>forn) then
          exit;

        { Greedily fold every following adjacent loop into s1's loop: after a
          successful fusion s1.left is again a single for-node, so a run
          L1;L2;L3;... collapses to one loop in one visit.  (foreachnodestatic
          also visits the inner statement nodes, but by the time it reaches them
          their slot is either the survivor loop -- whose next is no longer a
          for-node -- or an emptied/fixup slot, so they add nothing and stay
          quiet.) }
        { pre-initialize recognizer outputs (a nested function assigning parent
          locals defeats per-procedure DFA; see the matching note in the distpat
          pass). c1/ct1 are set once for the first pair and then reused across the
          greedy iterations (the fused survivor keeps loop 1's counter). }
        fusedany:=false;
        firstpair:=true;
        c1:=nil; c2:=nil; ct1:=nil; ct2:=nil;
        repeat
          s2:=fuse_next_meaningful(s1);
          if not assigned(s2) or not assigned(s2.left) or (s2.left.nodetype<>forn) then
            begin
              { diagnose only the first, un-fused candidate, to avoid noise }
              if not fusedany and assigned(s2) then
                MessagePos1(tfornode(s1.left).fileinfo,cg_n_loop_not_fused,
                  'the following statement is not a counted for-loop');
              break;
            end;

          forn1:=tfornode(s1.left);
          forn2:=tfornode(s2.left);
          c2:=nil; ct2:=nil;

          reason:=fuse_reason;
          if reason<>'' then
            begin
              if not fusedany then
                MessagePos1(forn1.fileinfo,cg_n_loop_not_fused,reason);
              break;
            end;

          { ---- build the fused loop body: A(i) ; B(i) ---- }
          body1copy:=forn1.t2.getcopy;
          body2copy:=forn2.t2.getcopy;

          newbody:=internalstatements(bstat);
          { two distinct counters: bind loop 2's counter to loop 1's at the top of
            each iteration (c2:=c1).  This makes loop 2's body see c2=i exactly as
            before, and -- because the assignment runs on every taken iteration and
            not at all when the loop is empty -- leaves c2 holding hi if the loop
            ran and unchanged otherwise, matching a stand-alone for-loop's post-
            value with no separate guarded fixup.  (A rename of c2->c1 would keep
            the body scalar-write-free and thus more vectorizable, but is left out
            here for robustness; same-counter fusions -- the common case -- carry
            no such assignment and vectorize unchanged.) }
          if c1<>c2 then
            addstatement(bstat,cassignmentnode.create(
              cloadnode.create(tsym(c2),c2.owner),
              cloadnode.create(tsym(c1),c1.owner)));
          addstatement(bstat,body1copy);
          addstatement(bstat,body2copy);

          fusedfor:=cfornode.create(
            cloadnode.create(tsym(c1),c1.owner),
            forn1.right.getcopy,
            forn1.t1.getcopy,
            newbody,
            false);
          do_firstpass(fusedfor);

          MessagePos(forn1.fileinfo,cg_n_loop_fused);
          s1.left:=fusedfor;
          s2.left:=cnothingnode.create;
          forn1.free;
          forn2.free;
          changed:=true;
          fusedany:=true;
          firstpair:=false;
        until false;
      end;


    function loopfuse_processfuse_cb(var n : tnode; arg : pointer) : foreachnoderesult;
      begin
        result:=fen_false;
        if n.nodetype=statementn then
          tloopfusecontext(arg^).processfuse(n);
      end;


    function OptimizeLoopFuse(node : tnode) : boolean;
      var
        ctx : tloopfusecontext;
      begin
        Result:=false;
        if not(pi_dfaavailable in current_procinfo.flags) then
          exit;
        ctx.changed:=false;
        { postorder so a chain L1;L2;L3 fuses L2+L3 first (when its statement node
          is visited) and then L1 with the already-merged loop, and so inner loops
          are considered before the statement list that holds them }
        foreachnodestatic(pm_postprocess,node,@loopfuse_processfuse_cb,@ctx);
        Result:=ctx.changed;
      end;


{*****************************************************************************
              Reduction reassociation (gcc -freassoc, fast-math gated)
*****************************************************************************}

    { A node-tree port of gcc's -freassoc / LLVM's reduction reassociation for
      the reduction shape

        for i := lo to hi do  acc := acc + expr(i);          (sum)
        for i := lo to hi do  acc := acc + a[i]*b[i];        (dot product)

      where acc is a simple local scalar used by no other statement in the loop.
      The single serial accumulator is a loop-carried dependency: iteration i+1's
      add cannot begin until iteration i's has retired, so the loop runs at the
      latency of one FP add per element however wide the machine is.  The pass
      splits acc into K=4 INDEPENDENT partial accumulators, each summing every
      fourth element, and combines them after the loop:

        s1:=0; s2:=0; s3:=0;  i:=lo;
        while i <= hi-3 do begin
          acc := acc + expr(i);       -- s0 keeps acc's incoming value
          s1  := s1  + expr(i+1);
          s2  := s2  + expr(i+2);
          s3  := s3  + expr(i+3);
          i := i+4;
        end;
        acc := (acc+s1) + (s2+s3);    -- combine
        while i <= hi do begin acc := acc + expr(i); i := i+1 end;   -- tail

      The four chains are independent, so four adds are in flight at once and the
      loop becomes throughput- rather than latency-bound (a ~3-4x speedup on a
      long single/double dot product on a machine with a 3-4-cycle-latency,
      1/cycle-throughput FP adder).  This is exactly neural-api's inner products
      (weight . activation) and L2/sum reductions over a TNNetVolume.

      SOUNDNESS.  Reassociating the additions changes the ORDER in which the
      partial sums are combined, hence the FP rounding -- so for a floating-point
      accumulator the pass fires ONLY under fast-math (cs_opt_fastmath), matching
      gcc's -ffast-math/-fassociative-math requirement.  For an integer
      accumulator two's-complement addition is exactly associative (even on
      overflow), so it is always safe -- except that -Co would trap on a different
      add, so checked code is declined.  The per-element contribution is unchanged
      (each element is added in the accumulator's precision exactly as before);
      only the grouping across elements differs.  The recognizer is strict and
      anything unmatched compiles exactly as before:

        * The loop is an ascending, unit-step counted for-loop over a simple non-
          aliased signed 32/64-bit counter (so i+1..i+3 and hi-3 cannot wrap for
          any index the original loop reached).
        * The body is exactly ONE plain (:=) assignment  acc := acc + expr  or
          acc := expr + acc, whose target acc is a simple non-aliased, non-
          address-taken, non-volatile local/value-param scalar of a floating-point
          or integer type.  The single-statement shape guarantees acc and the
          counter are written nowhere else in the loop.
        * expr is side-effect free and does not mention acc: it contains no call,
          no assignment, no address-of, no nested loop / control transfer, no
          write or modify of any location, and no non-pure inline intrinsic (only
          the pure single-argument arithmetic ones -- abs/sqr/sqrt and the min/max
          family -- are allowed).  Because expr writes nothing and acc is not
          address-taken, duplicating expr four times (with the counter shifted by
          i+1..i+3) reads the same values the serial loop would and produces no
          extra side effect; aliasing is irrelevant since nothing in the loop is
          stored except the local acc.
        * -Cr/-Co checked code is declined, and provably tiny constant-trip loops
          (< 2*K iterations) are left alone (no benefit, and peeling handles them).
        * Procedures with labels are skipped at the psub call site like the other
          loop passes, so control cannot enter the split body mid-stream. }

    const
      reassoc_k = 4;   { number of independent partial accumulators }

    type
      treassoc_safety = record
        accsym : tabstractvarsym;
        bad : boolean;
      end;
      preassoc_safety = ^treassoc_safety;

      treassoc_subst = record
        counter : tsym;
        delta : longint;
        ctype : tdef;
      end;
      preassoc_subst = ^treassoc_subst;


    function reassoc_safety_cb(var n : tnode; arg : pointer) : foreachnoderesult;
      { rejects any expr construct that would make duplicating it unsound: a
        write/modify of any location, a call, an address-of, an assignment, a
        nested loop or control transfer, a non-pure inline intrinsic, or a read of
        the accumulator itself (which must appear only as the reduction target) }
      begin
        result:=fen_false;
        if ([nf_write,nf_modify]*n.flags)<>[] then
          begin
            preassoc_safety(arg)^.bad:=true;
            exit(fen_norecurse_true);
          end;
        case n.nodetype of
          calln,addrn,assignn,forn,whilerepeatn,
          breakn,continuen,goton,labeln,exitn,raisen,tryexceptn,tryfinallyn,onn:
            begin
              preassoc_safety(arg)^.bad:=true;
              result:=fen_norecurse_true;
            end;
          inlinen:
            if not (tinlinenode(n).inlinenumber in
                 [in_abs_long,in_abs_real,in_sqr_real,in_sqrt_real,
                  in_min_single,in_max_single,in_min_double,in_max_double,
                  in_min_dword,in_max_dword,in_min_longint,in_max_longint,
                  in_min_qword,in_max_qword,in_min_int64,in_max_int64,
                  in_min_quad,in_max_quad]) then
              begin
                preassoc_safety(arg)^.bad:=true;
                result:=fen_norecurse_true;
              end;
          loadn:
            if tloadnode(n).symtableentry=tsym(preassoc_safety(arg)^.accsym) then
              begin
                preassoc_safety(arg)^.bad:=true;
                result:=fen_norecurse_true;
              end;
          else
            ;
        end;
      end;


    function reassoc_subst_cb(var n : tnode; arg : pointer) : foreachnoderesult;
      { wrap every plain read of the loop counter i into (i + delta), so a body
        copy computes expr(i+delta); returns fen_norecurse_false on a hit so the
        freshly built counter read inside the new add is not re-wrapped.  The new
        (i+delta) node is typechecked+firstpassed immediately: the surrounding expr
        is a copy of an already-typechecked body, so do_firstpass on the enclosing
        block will not descend into it -- but (i+delta) has the identical type as
        the plain counter read it replaces, so the ancestors' cached resultdefs
        stay valid and only this new subtree needs processing. }
      var
        ps : preassoc_subst;
      begin
        result:=fen_false;
        ps:=preassoc_subst(arg);
        if (n.nodetype=loadn) and (tloadnode(n).symtableentry=ps^.counter) and
           (([nf_write,nf_modify]*n.flags)=[]) then
          begin
            n:=caddnode.create(addn,n,cordconstnode.create(ps^.delta,ps^.ctype,false));
            do_firstpass(n);
            result:=fen_norecurse_false;
          end;
      end;


    function reassoc_zero(accdef : tdef) : tnode;
      { the additive identity of the accumulator type }
      begin
        if is_fpu(accdef) then
          result:=crealconstnode.create(0.0,accdef)
        else
          result:=cordconstnode.create(0,accdef,false);
      end;


    type
      treassoccontext = object
        changed : boolean;
        procedure processloop(var n : tnode);
      end;


    procedure treassoccontext.processloop(var n : tnode);
      var
        forn : tfornode;
        counter : tabstractvarsym;
        accsym : tabstractvarsym;
        ctype, accdef : tdef;
        stmt, lhs, rhs, la, ra, exprnode : tnode;
        assign : tassignmentnode;
        block, mainbody, tailbody, combine : tnode;
        stat, mstat, tstat : tstatementnode;
        lotemp, hitemp : ttempcreatenode;
        spart : array[1..reassoc_k-1] of ttempcreatenode;
        safety : treassoc_safety;
        subst : treassoc_subst;
        exprk, accref : tnode;
        j : longint;
        lo, hi : tconstexprint;

      function reassoc_reason : string;
        begin
          result:='';
          if lnf_backward in forn.loopflags then
            exit('descending (downto) loop');
          if assigned(forn.loopstep) then
            exit('non-unit loop step');

          { counter: simple non-aliased signed 32/64-bit local/value-param }
          counter:=rangeelim_simple_var(forn.left);
          if not assigned(counter) then
            exit('loop counter is not a simple non-aliased variable');
          ctype:=forn.left.resultdef;
          if not assigned(ctype) or (ctype.typ<>orddef) then
            exit('loop counter is not an ordinal type');
          if not is_signed(ctype) or not(ctype.size in [4,8]) then
            exit('loop counter is not a signed 32/64-bit integer');

          if ([cs_check_range,cs_check_overflow]*current_settings.localswitches)<>[] then
            exit('range/overflow checking is enabled (-Cr/-Co)');

          { body: exactly one plain assignment  acc := acc + expr }
          stmt:=vect_body_single_stmt(forn.t2);
          if not assigned(stmt) then
            exit('loop body is empty or has multiple statements');
          if stmt.nodetype<>assignn then
            exit('loop body is not a single assignment statement');
          assign:=tassignmentnode(stmt);
          if assign.assigntype<>at_normal then
            exit('loop body assignment is not a plain assignment');

          { destination acc: a simple non-aliased local scalar of FP or integer
            type }
          lhs:=rangeelim_skip_typeconv(assign.left);
          if not assigned(lhs) or (lhs.nodetype<>loadn) then
            exit('reduction target is not a plain scalar variable');
          accsym:=rangeelim_simple_var(lhs);
          if not assigned(accsym) then
            exit('reduction target is not a simple non-aliased local scalar');
          accdef:=lhs.resultdef;
          if not assigned(accdef) then
            exit('reduction target has no known type');
          if is_fpu(accdef) then
            begin
              if not(cs_opt_fastmath in current_settings.optimizerswitches) then
                exit('floating-point reduction needs fast-math (-OoFASTMATH) to reassociate');
            end
          else if not(is_ordinal(accdef) and (accdef.typ=orddef) and (accdef.size in [1,2,4,8])) then
            exit('reduction accumulator is neither a floating-point nor an integer scalar');

          { RHS must be  acc + expr  or  expr + acc }
          rhs:=rangeelim_skip_typeconv(assign.right);
          if not assigned(rhs) or (rhs.nodetype<>addn) then
            exit('right-hand side is not an addition into the accumulator');
          if taddnode(rhs).nodetype<>addn then
            exit('right-hand side is not an addition into the accumulator');
          la:=rangeelim_skip_typeconv(taddnode(rhs).left);
          ra:=rangeelim_skip_typeconv(taddnode(rhs).right);
          if assigned(la) and (la.nodetype=loadn) and (tloadnode(la).symtableentry=tsym(accsym)) then
            exprnode:=taddnode(rhs).right
          else if assigned(ra) and (ra.nodetype=loadn) and (tloadnode(ra).symtableentry=tsym(accsym)) then
            exprnode:=taddnode(rhs).left
          else
            exit('the addition does not have the accumulator as one operand');

          { expr side-effect free and free of any further accumulator reference }
          safety.accsym:=accsym;
          safety.bad:=false;
          foreachnodestatic(exprnode,@reassoc_safety_cb,@safety);
          if safety.bad then
            exit('the added expression has side effects, references the accumulator, or contains a call/non-pure intrinsic');

          { leave provably tiny constant-trip loops alone }
          if rangeelim_const_value(forn.right,lo) and rangeelim_const_value(forn.t1,hi) and
             ((hi-lo+1) < 2*reassoc_k) then
            exit('trip count is a small compile-time constant (not worth splitting)');
        end;

      begin
        forn:=tfornode(n);

        { pre-initialize recognizer outputs (a nested function assigning parent
          locals defeats per-procedure DFA; see the matching note in the sibling
          passes) }
        counter:=nil;
        accsym:=nil;
        ctype:=nil;
        accdef:=nil;
        assign:=nil;
        exprnode:=nil;

        if reassoc_reason<>'' then
          begin
            MessagePos1(forn.fileinfo,cg_n_loop_not_reassociated,reassoc_reason);
            exit;
          end;

        { ---- build the replacement block ---- }
        block:=internalstatements(stat);

        { lo := <start>;  hi := <end>  (evaluated once) }
        lotemp:=ctempcreatenode.create(ctype,ctype.size,tt_persistent,true);
        addstatement(stat,lotemp);
        addstatement(stat,cassignmentnode.create(ctemprefnode.create(lotemp),forn.right.getcopy));
        hitemp:=ctempcreatenode.create(ctype,ctype.size,tt_persistent,true);
        addstatement(stat,hitemp);
        addstatement(stat,cassignmentnode.create(ctemprefnode.create(hitemp),forn.t1.getcopy));

        { i := lo }
        addstatement(stat,cassignmentnode.create(
          cloadnode.create(tsym(counter),counter.owner),
          ctemprefnode.create(lotemp)));

        { partial accumulators s1..s(K-1) := 0  (s0 is acc itself, keeping its
          incoming value) }
        for j:=1 to reassoc_k-1 do
          begin
            spart[j]:=ctempcreatenode.create(accdef,accdef.size,tt_persistent,true);
            addstatement(stat,spart[j]);
            addstatement(stat,cassignmentnode.create(ctemprefnode.create(spart[j]),reassoc_zero(accdef)));
          end;

        { main loop:  while i<=hi-(K-1) do begin K independent adds; i:=i+K end }
        mainbody:=internalstatements(mstat);
        for j:=0 to reassoc_k-1 do
          begin
            if j=0 then
              accref:=cloadnode.create(tsym(accsym),accsym.owner)
            else
              accref:=ctemprefnode.create(spart[j]);
            exprk:=exprnode.getcopy;
            if j>0 then
              begin
                subst.counter:=tsym(counter);
                subst.delta:=j;
                subst.ctype:=ctype;
                foreachnodestatic(pm_postprocess,exprk,@reassoc_subst_cb,@subst);
              end;
            addstatement(mstat,cassignmentnode.create(accref,
              caddnode.create(addn,accref.getcopy,exprk)));
          end;
        addstatement(mstat,cassignmentnode.create(
          cloadnode.create(tsym(counter),counter.owner),
          caddnode.create(addn,cloadnode.create(tsym(counter),counter.owner),
            cordconstnode.create(reassoc_k,ctype,false))));
        addstatement(stat,cwhilerepeatnode.create(
          caddnode.create(lten,cloadnode.create(tsym(counter),counter.owner),
            caddnode.create(subn,ctemprefnode.create(hitemp),
              cordconstnode.create(reassoc_k-1,ctype,false))),
          mainbody,true,false));

        { combine:  acc := (acc + s1) + (s2 + s3)   (balanced tree, K=4) }
        combine:=caddnode.create(addn,
          caddnode.create(addn,
            cloadnode.create(tsym(accsym),accsym.owner),
            ctemprefnode.create(spart[1])),
          caddnode.create(addn,
            ctemprefnode.create(spart[2]),
            ctemprefnode.create(spart[3])));
        addstatement(stat,cassignmentnode.create(
          cloadnode.create(tsym(accsym),accsym.owner),combine));

        { scalar remainder:  while i<=hi do begin <original body>; i:=i+1 end }
        tailbody:=internalstatements(tstat);
        addstatement(tstat,forn.t2.getcopy);
        addstatement(tstat,cassignmentnode.create(
          cloadnode.create(tsym(counter),counter.owner),
          caddnode.create(addn,cloadnode.create(tsym(counter),counter.owner),
            cordconstnode.create(1,ctype,false))));
        addstatement(stat,cwhilerepeatnode.create(
          caddnode.create(lten,cloadnode.create(tsym(counter),counter.owner),
            ctemprefnode.create(hitemp)),
          tailbody,true,false));

        { release temps }
        addstatement(stat,ctempdeletenode.create(lotemp));
        addstatement(stat,ctempdeletenode.create(hitemp));
        for j:=1 to reassoc_k-1 do
          addstatement(stat,ctempdeletenode.create(spart[j]));

        do_firstpass(block);
        MessagePos1(forn.fileinfo,cg_n_loop_reassociated,tostr(reassoc_k));
        forn.free;
        n:=block;
        changed:=true;
      end;


    function reassoc_processloop_cb(var n : tnode; arg : pointer) : foreachnoderesult;
      begin
        result:=fen_false;
        if n.nodetype=forn then
          begin
            treassoccontext(arg^).processloop(n);
            { n may now be a block; do not recurse into the freed for-node }
            result:=fen_norecurse_false;
          end;
      end;


    function OptimizeReassoc(node : tnode) : boolean;
      var
        ctx : treassoccontext;
      begin
        Result:=false;
        if (cs_opt_size in current_settings.optimizerswitches) then
          exit;
        ctx.changed:=false;
        { postorder so an inner reduction loop is split before an enclosing loop }
        foreachnodestatic(pm_postprocess,node,@reassoc_processloop_cb,@ctx);
        Result:=ctx.changed;
      end;


{*****************************************************************************
                       Unroll-and-jam (gcc -funroll-and-jam)
*****************************************************************************}

    { A node-tree port of gcc's -funroll-and-jam / LLVM's loop-unroll-and-jam for
      a perfect (or near-perfect) two-level counted loop nest.  The OUTER loop is
      unrolled by a small factor K and the K resulting duplicated INNER loops are
      fused (jammed) into a single inner loop, so a value the inner body loads
      once (e.g. b[j] in a matmul-shaped  for i .. for j .. c[i]:=c[i]+a[i,j]*b[j])
      is reused across the K unrolled outer iterations straight from a register
      instead of being reloaded from memory on every outer pass, and a scalar
      accumulator kept per outer iteration is register-blocked:

        for i:=lo to hi do          -->   i:=lo;
        begin                             while i<=hi-(K-1) do begin
          s:=0;                             s0:=0; s1:=0; ... ;
          for j:=lo2 to hi2 do              for j:=lo2 to hi2 do begin
            s:=s+a[i,j]*b[j];                 s0:=s0+a[i  ,j]*b[j];   (b[j] loaded)
          c[i]:=s;                            s1:=s1+a[i+1,j]*b[j];   (b[j] reused)
        end;                                  ... end;
                                            c[i]:=s0; c[i+1]:=s1; ... ;
                                            i:=i+K;
                                          end;
                                          while i<=hi do begin        (remainder)
                                            s:=0; for j:=lo2 to hi2 do s:=s+a[i,j]*b[j];
                                            c[i]:=s; i:=i+1;
                                          end;

      DEPENDENCE / LEGALITY (a wrong jam is a miscompile; the recognizer is strict
      and anything not matched compiles exactly as before).  Jamming the K inner
      loops is the same reordering as fusing K copies of the inner body that run
      on outer indices i, i+1, ... i+K-1, so it is legal iff those copies touch
      provably disjoint memory (no loop-carried dependence across the outer loop).
      One blunt, sufficient rule guarantees it instead of a general dependence
      test:

        * The ONLY writes the outer body performs are (a) to a simple non-aliased
          LOCAL SCALAR accumulator -- renamed to a fresh per-copy temp in copies
          1..K-1 (the register-blocking payoff) and required dead outside the
          whole nest so the rename cannot change any observable value -- or (b) to
          an ARRAY ELEMENT whose subscript chain mentions the outer counter i, so
          copy k writes the i+k slice and the K copies' stores are disjoint.
        * The outer counter i may appear in the body ONLY as an exact array
          subscript  [i]  (unit stride, no i+/-c offset and never in a scalar
          computation or the inner-loop bounds).  Hence every array reference that
          copy k could touch through i lives at index i+k, disjoint across copies;
          arrays not mentioning i are never written (a write must be scalar or
          i-indexed) so they are read-only and shared safely, and the inner
          iteration space is i-invariant so the jam is well-defined.  (Enforced by
          counting: every read of i must coincide with a bare [i] subscript.)
        * No calls, pointer dereferences, address-of, non-pure inline intrinsics
          (only the abs/sqr/sqrt and min/max whitelist), and exactly ONE nested
          loop -- the inner counted for -- with no other loop anywhere; no
          break/continue/goto/label/exit/raise/try; only plain (:=) assignments.
        * -Cr/-Co checked code is declined (the unroll reorders the per-element
          checks); both loops ascending, unit step, over simple non-aliased
          signed 32/64-bit counters i<>j (so i+1..i+K-1 and hi-(K-1) cannot wrap
          for any index the loop reached).
        * The enclosing routine has no labels (checked at the psub call site, like
          the sibling loop passes) so control cannot enter a jammed body mid-way,
          and DFA proves i is not assigned inside the body. }

    const
      ujam_k = 4;       { outer unroll (and inner jam) factor }
      ujam_maxaccum = 8;  { cap renamed scalar accumulators to bound expansion }

    type
      tujam_scan = record
        counter_i : tsym;
        counter_j : tsym;
        innerforcount : longint;
        otherloopcount : longint;
        iload_total : longint;       { reads of i anywhere in the body }
        iload_subscript : longint;   { vecn whose direct index is exactly i }
        accsyms : array of tsym;
        accdefs : array of tdef;
        naccums : longint;
        bad : boolean;
        badreason : string;
      end;
      pujam_scan = ^tujam_scan;

      tujam_subst = record
        counter_i : tsym;
        delta : longint;
        ctype : tdef;
        naccums : longint;
        accsyms : array of tsym;
        acctemps : array of ttempcreatenode;
      end;
      pujam_subst = ^tujam_subst;

      tujam_refcount = record
        sym : tsym;
        count : longint;
      end;
      pujam_refcount = ^tujam_refcount;


    function ujam_refcount_cb(var n : tnode; arg : pointer) : foreachnoderesult;
      begin
        result:=fen_false;
        if (n.nodetype=loadn) and (tloadnode(n).symtableentry=pujam_refcount(arg)^.sym) then
          inc(pujam_refcount(arg)^.count);
      end;


    function ujam_count_refs(subtree : tnode; sym : tsym) : longint;
      var
        rc : tujam_refcount;
      begin
        result:=0;
        if not assigned(subtree) then
          exit;
        rc.sym:=sym;
        rc.count:=0;
        foreachnodestatic(subtree,@ujam_refcount_cb,@rc);
        result:=rc.count;
      end;


    function ujam_body_cb(var n : tnode; arg : pointer) : foreachnoderesult;
      { validates every construct in the outer-loop body against the legality rule
        above and, as a side effect, records the (single) inner counter, the set
        of scalar-accumulator syms, and the i-read / i-subscript tallies used by
        the caller to prove i appears only as a bare array subscript }
      var
        ps : pujam_scan;
        idx, lhs : tnode;
        s : tabstractvarsym;
        a : longint;
      begin
        result:=fen_false;
        ps:=pujam_scan(arg);
        case n.nodetype of
          calln:
            begin
              ps^.bad:=true; ps^.badreason:='body contains a call';
              exit(fen_norecurse_true);
            end;
          derefn,addrn:
            begin
              ps^.bad:=true;
              ps^.badreason:='body dereferences or takes the address of a pointer (aliasing cannot be proven)';
              exit(fen_norecurse_true);
            end;
          inlinen:
            if not (tinlinenode(n).inlinenumber in
                 [in_abs_long,in_abs_real,in_sqr_real,in_sqrt_real,
                  in_min_single,in_max_single,in_min_double,in_max_double,
                  in_min_dword,in_max_dword,in_min_longint,in_max_longint,
                  in_min_qword,in_max_qword,in_min_int64,in_max_int64,
                  in_min_quad,in_max_quad]) then
              begin
                ps^.bad:=true;
                ps^.badreason:='body contains a non-pure inline intrinsic';
                exit(fen_norecurse_true);
              end;
          whilerepeatn:
            begin
              inc(ps^.otherloopcount);
              ps^.bad:=true; ps^.badreason:='body contains a while/repeat loop';
              exit(fen_norecurse_true);
            end;
          forn:
            begin
              inc(ps^.innerforcount);
              if ps^.innerforcount>1 then
                begin
                  ps^.bad:=true; ps^.badreason:='body contains more than one nested for-loop';
                  exit(fen_norecurse_true);
                end;
              { the single nested inner counted loop: ascending, unit step, a
                simple non-aliased ordinal counter distinct from i }
              if lnf_backward in tfornode(n).loopflags then
                begin
                  ps^.bad:=true; ps^.badreason:='inner loop is descending (downto)';
                  exit(fen_norecurse_true);
                end;
              if assigned(tfornode(n).loopstep) then
                begin
                  ps^.bad:=true; ps^.badreason:='inner loop has a non-unit step';
                  exit(fen_norecurse_true);
                end;
              s:=rangeelim_simple_var(tfornode(n).left);
              if not assigned(s) then
                begin
                  ps^.bad:=true; ps^.badreason:='inner loop counter is not a simple non-aliased variable';
                  exit(fen_norecurse_true);
                end;
              if not assigned(tfornode(n).left.resultdef) or (tfornode(n).left.resultdef.typ<>orddef) then
                begin
                  ps^.bad:=true; ps^.badreason:='inner loop counter is not an ordinal type';
                  exit(fen_norecurse_true);
                end;
              if tsym(s)=ps^.counter_i then
                begin
                  ps^.bad:=true; ps^.badreason:='inner loop reuses the outer loop counter';
                  exit(fen_norecurse_true);
                end;
              ps^.counter_j:=tsym(s);
              { descend normally into the inner for's bounds/body -- they are held
                to the same rule (any i they mention shows up in iload_total but
                not as a subscript, so a bound or offset use of i is rejected) }
            end;
          breakn,continuen,goton,labeln,exitn,raisen,tryexceptn,tryfinallyn,onn:
            begin
              ps^.bad:=true;
              ps^.badreason:='body contains break/continue/goto/label/exit/raise/try';
              exit(fen_norecurse_true);
            end;
          assignn:
            begin
              if tassignmentnode(n).assigntype<>at_normal then
                begin
                  ps^.bad:=true; ps^.badreason:='body has a non-plain (compound) assignment';
                  exit(fen_norecurse_true);
                end;
              lhs:=rangeelim_skip_typeconv(tassignmentnode(n).left);
              if not assigned(lhs) then
                begin
                  ps^.bad:=true; ps^.badreason:='assignment has no target';
                  exit(fen_norecurse_true);
                end;
              if lhs.nodetype=loadn then
                begin
                  { a scalar store: must be a simple non-aliased local we can
                    rename per copy; recorded as an accumulator }
                  s:=rangeelim_simple_var(lhs);
                  if not assigned(s) then
                    begin
                      ps^.bad:=true;
                      ps^.badreason:='body writes a scalar that is not a simple non-aliased local (cannot rename per copy)';
                      exit(fen_norecurse_true);
                    end;
                  if (tsym(s)=ps^.counter_i) or (tsym(s)=ps^.counter_j) then
                    begin
                      ps^.bad:=true; ps^.badreason:='body assigns a loop counter';
                      exit(fen_norecurse_true);
                    end;
                  { dedupe }
                  for a:=0 to ps^.naccums-1 do
                    if ps^.accsyms[a]=tsym(s) then
                      exit(fen_false);
                  if ps^.naccums>=ujam_maxaccum then
                    begin
                      ps^.bad:=true; ps^.badreason:='too many distinct scalar accumulators';
                      exit(fen_norecurse_true);
                    end;
                  if not assigned(lhs.resultdef) then
                    begin
                      ps^.bad:=true; ps^.badreason:='scalar accumulator has no known type';
                      exit(fen_norecurse_true);
                    end;
                  SetLength(ps^.accsyms,ps^.naccums+1);
                  SetLength(ps^.accdefs,ps^.naccums+1);
                  ps^.accsyms[ps^.naccums]:=tsym(s);
                  ps^.accdefs[ps^.naccums]:=lhs.resultdef;
                  inc(ps^.naccums);
                end
              else if lhs.nodetype=vecn then
                begin
                  { an array-element store: must mention i so the K copies write
                    disjoint outer slices }
                  if ujam_count_refs(lhs,ps^.counter_i)=0 then
                    begin
                      ps^.bad:=true;
                      ps^.badreason:='an array store is not indexed by the outer counter (would collide across unrolled copies)';
                      exit(fen_norecurse_true);
                    end;
                end
              else
                begin
                  ps^.bad:=true;
                  ps^.badreason:='body writes a field, pointer or other non-renamable target';
                  exit(fen_norecurse_true);
                end;
            end;
          vecn:
            begin
              idx:=rangeelim_skip_typeconv(tvecnode(n).right);
              if assigned(idx) and (idx.nodetype=loadn) and
                 (tloadnode(idx).symtableentry=ps^.counter_i) then
                inc(ps^.iload_subscript);
            end;
          loadn:
            if (tloadnode(n).symtableentry=ps^.counter_i) and
               (([nf_write,nf_modify]*n.flags)=[]) then
              inc(ps^.iload_total);
          else
            ;
        end;
      end;


    function ujam_subst_cb(var n : tnode; arg : pointer) : foreachnoderesult;
      { in a copy of the outer body for unrolled iteration i+delta: wrap every
        plain read of the outer counter i into (i+delta), and replace every read
        or write of an accumulator scalar with its fresh per-copy temp.  Each new
        node is typechecked immediately (the surrounding body is a copy of an
        already-typechecked tree do_firstpass will not re-descend into, but the
        substituted node has the identical type of what it replaced, so ancestor
        resultdefs stay valid) -- the REASSOC substitution gotcha. }
      var
        ps : pujam_subst;
        a : longint;
        newref : ttemprefnode;
      begin
        result:=fen_false;
        ps:=pujam_subst(arg);
        if n.nodetype<>loadn then
          exit;
        if (ps^.delta<>0) and (tloadnode(n).symtableentry=ps^.counter_i) and
           (([nf_write,nf_modify]*n.flags)=[]) then
          begin
            n:=caddnode.create(addn,n,cordconstnode.create(ps^.delta,ps^.ctype,false));
            do_firstpass(n);
            exit(fen_norecurse_false);
          end;
        for a:=0 to ps^.naccums-1 do
          if tloadnode(n).symtableentry=ps^.accsyms[a] then
            begin
              newref:=ctemprefnode.create(ps^.acctemps[a]);
              newref.flags:=newref.flags+(n.flags*[nf_write,nf_modify]);
              n:=newref;
              do_firstpass(n);
              exit(fen_norecurse_false);
            end;
      end;


    type
      tunrolljamcontext = object
        changed : boolean;
        root : tnode;
        procedure processloop(var n : tnode);
      end;


    procedure tunrolljamcontext.processloop(var n : tnode);
      var
        outerfor, innerfor : tfornode;
        counter_i : tabstractvarsym;
        ctype : tdef;
        scan : tujam_scan;
        prologue, epilogue : array of tnode;
        nprologue, nepilogue : longint;
        acctemps : array[1..ujam_k-1] of array of ttempcreatenode;
        lotemp, hitemp : ttempcreatenode;
        block, mainbody, tailbody, jambody : tnode;
        stat, mstat, jstat, tstat : tstatementnode;
        subst : tujam_subst;
        k, a : longint;
        lo, hi : tconstexprint;

      function ujam_copy(orig : tnode; kk : longint) : tnode;
        var
          aa : longint;
        begin
          result:=orig.getcopy;
          if kk>0 then
            begin
              subst.counter_i:=tsym(counter_i);
              subst.delta:=kk;
              subst.ctype:=ctype;
              subst.naccums:=scan.naccums;
              subst.accsyms:=scan.accsyms;
              SetLength(subst.acctemps,scan.naccums);
              for aa:=0 to scan.naccums-1 do
                subst.acctemps[aa]:=acctemps[kk][aa];
              foreachnodestatic(pm_postprocess,result,@ujam_subst_cb,@subst);
            end;
        end;

      function ujam_reason : string;
        var
          body, cur : tnode;
          stmtlist : tnode;
          idx, i2 : longint;
          tmparr : array of tnode;
          ntmp : longint;
          hascheck : boolean;
        begin
          result:='';
          if lnf_backward in outerfor.loopflags then
            exit('outer loop is descending (downto)');
          if assigned(outerfor.loopstep) then
            exit('outer loop has a non-unit step');

          counter_i:=rangeelim_simple_var(outerfor.left);
          if not assigned(counter_i) then
            exit('outer loop counter is not a simple non-aliased variable');
          ctype:=outerfor.left.resultdef;
          if not assigned(ctype) or (ctype.typ<>orddef) then
            exit('outer loop counter is not an ordinal type');
          if not is_signed(ctype) or not(ctype.size in [4,8]) then
            exit('outer loop counter is not a signed 32/64-bit integer');

          if ([cs_check_range,cs_check_overflow]*current_settings.localswitches)<>[] then
            exit('range/overflow checking is enabled (-Cr/-Co)');
          { also decline a body that carries a per-region R+ or Q+ }
          hascheck:=false;
          if foreachnodestatic(outerfor.t2,@vect_check_cb,@hascheck) then
            exit('body has per-region range/overflow checking');

          if not assigned(outerfor.t2) then
            exit('outer loop body is empty');
          if not fuse_bound_pure(outerfor.right) or not fuse_bound_pure(outerfor.t1) then
            exit('outer loop bounds are not side-effect free');

          { scan the whole body for legality and to collect the inner counter and
            the accumulator set }
          scan.counter_i:=tsym(counter_i);
          scan.counter_j:=nil;
          scan.innerforcount:=0;
          scan.otherloopcount:=0;
          scan.iload_total:=0;
          scan.iload_subscript:=0;
          scan.naccums:=0;
          scan.bad:=false;
          scan.badreason:='';
          SetLength(scan.accsyms,0);
          SetLength(scan.accdefs,0);
          foreachnodestatic(outerfor.t2,@ujam_body_cb,@scan);
          if scan.bad then
            exit(scan.badreason);
          if scan.innerforcount<>1 then
            exit('outer body does not contain exactly one nested counted loop');
          if scan.iload_total<>scan.iload_subscript then
            exit('the outer counter is used outside a bare array subscript (offset index, bound or scalar use)');

          { DFA: the outer counter must not be assigned in the body }
          CalcDefSum(outerfor.t2);
          if not assigned(outerfor.t2.optinfo) or not assigned(outerfor.left.optinfo) then
            exit('data-flow information is unavailable for the loop body');
          if DynSetIn(outerfor.t2.optinfo^.defsum,outerfor.left.optinfo^.index) then
            exit('outer loop counter is modified inside the body');

          { every renamed scalar accumulator must be dead outside the whole nest,
            so renaming it per unrolled copy cannot change any observable value:
            all of its references must lie inside this outer for-node }
          for i2:=0 to scan.naccums-1 do
            if ujam_count_refs(root,scan.accsyms[i2])<>ujam_count_refs(outerfor,scan.accsyms[i2]) then
              exit('a scalar accumulator is live outside the loop nest (cannot safely rename)');

          { locate the inner for as a top-level statement of the body and split
            the surrounding prologue / epilogue around it }
          body:=outerfor.t2;
          if body.nodetype=blockn then
            body:=tblocknode(body).left;
          SetLength(tmparr,0);
          ntmp:=0;
          stmtlist:=body;
          while assigned(stmtlist) and (stmtlist.nodetype=statementn) do
            begin
              cur:=tstatementnode(stmtlist).left;
              if assigned(cur) and (cur.nodetype<>nothingn) then
                begin
                  SetLength(tmparr,ntmp+1);
                  tmparr[ntmp]:=cur;
                  inc(ntmp);
                end;
              stmtlist:=tstatementnode(stmtlist).right;
            end;
          if (ntmp=0) and (body.nodetype=forn) then
            begin
              { the body is a bare unwrapped for-loop (no prologue/epilogue) }
              SetLength(tmparr,1);
              tmparr[0]:=body;
              ntmp:=1;
            end;
          idx:=-1;
          for i2:=0 to ntmp-1 do
            if tmparr[i2].nodetype=forn then
              begin
                if idx>=0 then
                  exit('multiple top-level loops in the outer body');
                idx:=i2;
              end;
          if idx<0 then
            exit('the nested loop is not a direct statement of the outer body');
          innerfor:=tfornode(tmparr[idx]);
          SetLength(prologue,idx);
          nprologue:=idx;
          for i2:=0 to idx-1 do
            prologue[i2]:=tmparr[i2];
          SetLength(epilogue,ntmp-idx-1);
          nepilogue:=ntmp-idx-1;
          for i2:=idx+1 to ntmp-1 do
            epilogue[i2-idx-1]:=tmparr[i2];

          { leave a provably tiny constant-trip outer loop alone -- the unrolled
            main body would never run }
          if rangeelim_const_value(outerfor.right,lo) and rangeelim_const_value(outerfor.t1,hi) and
             ((hi-lo+1) < ujam_k) then
            exit('outer trip count is a small compile-time constant (not worth unrolling)');
        end;

      begin
        outerfor:=tfornode(n);

        { pre-initialize recognizer outputs (a nested function assigning parent
          locals defeats per-procedure DFA; see the sibling passes) }
        counter_i:=nil;
        ctype:=nil;
        innerfor:=nil;
        nprologue:=0;
        nepilogue:=0;
        { fully initialize the managed-type recognizer record here too: it is
          populated inside ujam_reason (a nested function), which per-procedure
          DFA cannot see, so without this the -O4 -Sew self-compile flags scan as
          possibly-uninitialized }
        scan.counter_i:=nil;
        scan.counter_j:=nil;
        scan.innerforcount:=0;
        scan.otherloopcount:=0;
        scan.iload_total:=0;
        scan.iload_subscript:=0;
        scan.naccums:=0;
        scan.bad:=false;
        scan.badreason:='';
        SetLength(scan.accsyms,0);
        SetLength(scan.accdefs,0);
        SetLength(prologue,0);
        SetLength(epilogue,0);
        SetLength(subst.accsyms,0);
        SetLength(subst.acctemps,0);
        for k:=1 to ujam_k-1 do
          SetLength(acctemps[k],0);

        if ujam_reason<>'' then
          begin
            MessagePos1(outerfor.fileinfo,cg_n_loop_not_unrolljammed,ujam_reason);
            exit;
          end;

        { ---- build the replacement block ---- }
        block:=internalstatements(stat);

        { lo := <start>;  hi := <end>  (evaluated once, as a for-loop would) }
        lotemp:=ctempcreatenode.create(ctype,ctype.size,tt_persistent,true);
        addstatement(stat,lotemp);
        addstatement(stat,cassignmentnode.create(ctemprefnode.create(lotemp),outerfor.right.getcopy));
        hitemp:=ctempcreatenode.create(ctype,ctype.size,tt_persistent,true);
        addstatement(stat,hitemp);
        addstatement(stat,cassignmentnode.create(ctemprefnode.create(hitemp),outerfor.t1.getcopy));

        { i := lo }
        addstatement(stat,cassignmentnode.create(
          cloadnode.create(tsym(counter_i),counter_i.owner),
          ctemprefnode.create(lotemp)));

        { fresh per-copy accumulator temps for copies 1..K-1 }
        for k:=1 to ujam_k-1 do
          begin
            SetLength(acctemps[k],scan.naccums);
            for a:=0 to scan.naccums-1 do
              begin
                acctemps[k][a]:=ctempcreatenode.create(scan.accdefs[a],scan.accdefs[a].size,tt_persistent,true);
                addstatement(stat,acctemps[k][a]);
              end;
          end;

        { main unrolled loop:  while i<=hi-(K-1) do begin ...; i:=i+K end }
        mainbody:=internalstatements(mstat);
        { all K prologue copies first (the accumulator inits) }
        for k:=0 to ujam_k-1 do
          for a:=0 to nprologue-1 do
            addstatement(mstat,ujam_copy(prologue[a],k));
        { the single jammed inner loop: its body is the K inner bodies back to
          back (all over the same counter j and iteration space) }
        jambody:=internalstatements(jstat);
        for k:=0 to ujam_k-1 do
          addstatement(jstat,ujam_copy(innerfor.t2,k));
        addstatement(mstat,cfornode.create(
          cloadnode.create(scan.counter_j,tabstractvarsym(scan.counter_j).owner),
          innerfor.right.getcopy,
          innerfor.t1.getcopy,
          jambody,
          false));
        { all K epilogue copies (the stores) }
        for k:=0 to ujam_k-1 do
          for a:=0 to nepilogue-1 do
            addstatement(mstat,ujam_copy(epilogue[a],k));
        { i := i + K }
        addstatement(mstat,cassignmentnode.create(
          cloadnode.create(tsym(counter_i),counter_i.owner),
          caddnode.create(addn,cloadnode.create(tsym(counter_i),counter_i.owner),
            cordconstnode.create(ujam_k,ctype,false))));
        addstatement(stat,cwhilerepeatnode.create(
          caddnode.create(lten,cloadnode.create(tsym(counter_i),counter_i.owner),
            caddnode.create(subn,ctemprefnode.create(hitemp),
              cordconstnode.create(ujam_k-1,ctype,false))),
          mainbody,true,false));

        { scalar remainder:  while i<=hi do begin <original outer body>; i:=i+1 end }
        tailbody:=internalstatements(tstat);
        addstatement(tstat,outerfor.t2.getcopy);
        addstatement(tstat,cassignmentnode.create(
          cloadnode.create(tsym(counter_i),counter_i.owner),
          caddnode.create(addn,cloadnode.create(tsym(counter_i),counter_i.owner),
            cordconstnode.create(1,ctype,false))));
        addstatement(stat,cwhilerepeatnode.create(
          caddnode.create(lten,cloadnode.create(tsym(counter_i),counter_i.owner),
            ctemprefnode.create(hitemp)),
          tailbody,true,false));

        { release temps }
        addstatement(stat,ctempdeletenode.create(lotemp));
        addstatement(stat,ctempdeletenode.create(hitemp));
        for k:=1 to ujam_k-1 do
          for a:=0 to scan.naccums-1 do
            addstatement(stat,ctempdeletenode.create(acctemps[k][a]));

        do_firstpass(block);
        MessagePos1(outerfor.fileinfo,cg_n_loop_unrolljammed,tostr(ujam_k));
        outerfor.free;
        n:=block;
        changed:=true;
      end;


    function ujam_processloop_cb(var n : tnode; arg : pointer) : foreachnoderesult;
      begin
        result:=fen_false;
        if n.nodetype=forn then
          begin
            tunrolljamcontext(arg^).processloop(n);
            { n may now be a block; do not recurse into the freed for-node }
            result:=fen_norecurse_false;
          end;
      end;


    function OptimizeUnrollJam(node : tnode) : boolean;
      var
        ctx : tunrolljamcontext;
      begin
        Result:=false;
        if (cs_opt_size in current_settings.optimizerswitches) then
          exit;
        if not(pi_dfaavailable in current_procinfo.flags) then
          exit;
        ctx.changed:=false;
        ctx.root:=node;
        { postorder so the innermost nest is considered first (the inner for
          declines for lack of its own nested loop, then the outer 2-level nest
          matches) }
        foreachnodestatic(pm_postprocess,node,@ujam_processloop_cb,@ctx);
        Result:=ctx.changed;
      end;


{*****************************************************************************
                   Jump threading / nested re-test elimination
*****************************************************************************}

    { A node-tree port of gcc's -fthread-jumps / VRP-based jump threading.  A
      full CFG-level threading pass is out of reach at the node level, but the
      practical win -- eliminating a re-test of a predicate that a dominating
      branch already decided -- maps directly onto the FPC node tree:

          if <cond> then <TB> else <EB>

      inside TB the predicate <cond> is known TRUE, and inside EB it is known
      FALSE.  Any *nested* if whose condition is decided by those facts is
      folded in place to the taken branch, deleting the redundant re-test (and
      the dead arm).  Because we only fold -- never duplicate a block -- there
      is no code growth and hence no I-cache budget to manage.

      Two fact kinds are tracked, both restricted to provably-safe conditions:

        * comparison facts  V <op> c  (op in = <> < <= > >=, c an ordinal
          constant, V a simple non-aliased non-volatile local/value-param).
          A nested comparison  V <op2> c2  on the *same* variable and the
          *same* signedness is decided by integer implication (jt_all_satisfy):
          the fact constrains V to a set S; the query is always-true if S is a
          subset of the query's truth set, always-false if S is disjoint from
          it, else undecided.  Reasoning is done on the unbounded integer line
          (the type's own domain bounds are only ever a *subset* of S, so
          ignoring them can only lose folds, never create an unsound one).

        * identical-predicate facts: any side-effect-free, call-free, memory-
          free condition built solely from constants, simple non-aliased var
          loads and pure operators; a nested condition that is tnode.isequal to
          it folds to the taken (or, in the else-branch, the not-taken) arm.

      Soundness gates (a wrong-way implication is a miscompile):
        * V (or, for identical-predicate facts, every variable in the
          condition) must be a simple non-aliased, non-address-taken, non-
          volatile, non-threadvar local or value parameter -- so no pointer,
          alias, or other-thread write can change it -- AND must not be
          assigned anywhere in the branch region the fact is asserted for
          (jt_writes_var scans for a write load or a for-loop that owns it).
          Address-not-taken already rules out by-ref parameter passing and
          SetLength-style aliasing, so an ordinary call on the path cannot
          touch V; combined with "unmodified in the whole region", the fact is
          invariant throughout the region and a re-test anywhere in it -- even
          inside a nested loop -- is decidable.
        * Facts inherited from an enclosing dominating if stay valid in every
          sub-region (their variable was already proven unmodified in the
          larger region), so they are carried down unconditionally and let a
          chained if/elsif ladder fold later re-tests of earlier decisions. }

    type
      tjtfact = record
        sym      : tabstractvarsym;   { the constrained variable (both kinds) }
        iscmp    : boolean;           { comparison fact vs identical-predicate }
        op       : tnodetype;         { cmp: the (normalized) relation  V op c  }
        c        : tconstexprint;     { cmp: the constant }
        signed   : boolean;           { cmp: signedness of the compare }
        origcond : tnode;             { isequal fact: the asserted condition }
        asserted : boolean;           { isequal fact: TRUE known / FALSE known }
      end;
      tjtfactarr = array of tjtfact;

      pjtenv = ^tjtenv;
      tjtenv = record
        facts   : tjtfactarr;
        changed : pboolean;
      end;


    { swap a relational operator for the case  c <op> V  ==  V <swap> c }
    function jt_swap_relop(op : tnodetype) : tnodetype;
      begin
        case op of
          ltn:  result:=gtn;
          gtn:  result:=ltn;
          lten: result:=gten;
          gten: result:=lten;
          else  result:=op;   { =, <> are symmetric }
        end;
      end;


    { logical negation of a relational operator }
    function jt_negate_relop(op : tnodetype) : tnodetype;
      begin
        case op of
          equaln:   result:=unequaln;
          unequaln: result:=equaln;
          ltn:      result:=gten;
          lten:     result:=gtn;
          gtn:      result:=lten;
          gten:     result:=ltn;
          else      result:=op;
        end;
      end;


    { evaluate a concrete  v <op> c  over the integers }
    function jt_eval_rel(const v : tconstexprint; op : tnodetype; const c : tconstexprint) : boolean;
      begin
        case op of
          equaln:   result:=v=c;
          unequaln: result:=v<>c;
          ltn:      result:=v<c;
          lten:     result:=v<=c;
          gtn:      result:=v>c;
          gten:     result:=v>=c;
          else      result:=false;
        end;
      end;


    { Describe the solution set of  V <op> c  as either a single value, the
      complement of a single value (<>), or a one-sided interval.
        kind: 0=interval [lo..hi] (haslo/hashi say which bounds are finite),
              1=single value (in lo), 2=all-but-one (the excluded value in lo). }
    procedure jt_relkind(op : tnodetype; const c : tconstexprint;
                         out lo, hi : tconstexprint; out haslo, hashi : boolean;
                         out kind : integer);
      begin
        lo:=c; hi:=c; haslo:=false; hashi:=false; kind:=0;
        case op of
          equaln:
            begin kind:=1; lo:=c; end;
          unequaln:
            begin kind:=2; lo:=c; end;
          ltn:
            begin kind:=0; hashi:=true; hi:=c-1; end;
          lten:
            begin kind:=0; hashi:=true; hi:=c; end;
          gtn:
            begin kind:=0; haslo:=true; lo:=c+1; end;
          gten:
            begin kind:=0; haslo:=true; lo:=c; end;
          else
            { other comparison node types are not passed here; the defaults set
              above stand. Explicit else silences the case-exhaustiveness warning
              that -Sew promotes to an error on self-compile. }
            ;
        end;
      end;


    { True iff every integer V satisfying the fact  V <fop> fc  also satisfies
      the query  V <qop> qc .  Both relations are on the same variable and the
      same signedness, so plain numeric comparison of the constants matches the
      compare order (unsigned constants are non-negative -> numeric == unsigned
      order; signed constants -> numeric == signed order). }
    function jt_all_satisfy(fop : tnodetype; const fc : tconstexprint;
                            qop : tnodetype; const qc : tconstexprint) : boolean;
      var
        flo, fhi, qlo, qhi : tconstexprint;
        fhaslo, fhashi, qhaslo, qhashi : boolean;
        fkind, qkind : integer;
        lowerok, upperok : boolean;
      begin
        result:=false;
        jt_relkind(fop,fc,flo,fhi,fhaslo,fhashi,fkind);
        jt_relkind(qop,qc,qlo,qhi,qhaslo,qhashi,qkind);
        case fkind of
          1: { fact fixes V = flo: just evaluate the query there }
            result:=jt_eval_rel(flo,qop,qc);
          2: { fact is  V <> flo (everything but one point). The query holds for
               all of that only if the query itself is  V <> flo }
            result:=(qkind=2) and (qlo=flo);
          0: { fact is a one-sided interval }
            case qkind of
              1: { infinite interval can never be a subset of a single point }
                result:=false;
              2: { subset of  V <> qc  iff the excluded point qc is outside S }
                result:=(fhaslo and (qlo<flo)) or (fhashi and (qlo>fhi));
              0: { subset of the query interval: query must cover both ends of S }
                begin
                  lowerok:=(not qhaslo) or (fhaslo and (flo>=qlo));
                  upperok:=(not qhashi) or (fhashi and (fhi<=qhi));
                  result:=lowerok and upperok;
                end;
              else
                ; { jt_relkind only yields kind 0/1/2; keep result=false }
            end;
          else
            ; { jt_relkind only yields kind 0/1/2; keep result=false }
        end;
      end;


    { Recognize a condition of the form  V <op> const  (or  const <op> V ), with
      V a simple non-aliased local/value-param of ordinal type and the compare
      side-effect free.  Returns the normalized  V <op> c  plus its signedness. }
    function jt_recognize_cmp(cond : tnode; out sym : tabstractvarsym;
                              out op : tnodetype; out c : tconstexprint;
                              out signed : boolean) : boolean;
      var
        l, r : tnode;
      begin
        result:=false;
        sym:=nil;
        if not assigned(cond) then
          exit;
        if not(cond.nodetype in [equaln,unequaln,ltn,lten,gtn,gten]) then
          exit;
        if ([nf_write,nf_modify]*cond.flags)<>[] then
          exit;
        l:=taddnode(cond).left;
        r:=taddnode(cond).right;
        { var on the left, constant on the right }
        if rangeelim_const_value(r,c) then
          begin
            sym:=rangeelim_simple_var(rangeelim_skip_typeconv(l));
            if assigned(sym) and assigned(l.resultdef) and is_ordinal(l.resultdef) then
              begin
                op:=cond.nodetype;
                signed:=is_signed(l.resultdef);
                exit(true);
              end;
            sym:=nil;
          end;
        { constant on the left, var on the right:  c <op> V  ==  V <swap> c }
        if rangeelim_const_value(l,c) then
          begin
            sym:=rangeelim_simple_var(rangeelim_skip_typeconv(r));
            if assigned(sym) and assigned(r.resultdef) and is_ordinal(r.resultdef) then
              begin
                op:=jt_swap_relop(cond.nodetype);
                signed:=is_signed(r.resultdef);
                exit(true);
              end;
            sym:=nil;
          end;
      end;


    { scan state for jt_writes_var }
    type
      pjtwritescan = ^tjtwritescan;
      tjtwritescan = record
        sym   : tabstractvarsym;
        found : boolean;
      end;

    function jt_writescan_cb(var n : tnode; arg : pointer) : foreachnoderesult;
      var
        p : pjtwritescan;
      begin
        result:=fen_false;
        p:=pjtwritescan(arg);
        if (n.nodetype=loadn) and (tloadnode(n).symtableentry=tsym(p^.sym)) and
           (([nf_write,nf_modify]*n.flags)<>[]) then
          begin
            p^.found:=true;
            result:=fen_norecurse_true;
          end
        { a for-loop assigns its counter variable each iteration }
        else if (n.nodetype=forn) and assigned(tfornode(n).left) and
                (tfornode(n).left.nodetype=loadn) and
                (tloadnode(tfornode(n).left).symtableentry=tsym(p^.sym)) then
          begin
            p^.found:=true;
            result:=fen_norecurse_true;
          end;
      end;

    { True if the variable sym is (or might be) assigned anywhere in subtree.
      addr_taken is already excluded by rangeelim_simple_var, so a write can
      only appear as a write/modify load or a for-loop over the variable. }
    function jt_writes_var(subtree : tnode; sym : tabstractvarsym) : boolean;
      var
        scan : tjtwritescan;
      begin
        result:=false;
        if not assigned(subtree) then
          exit;
        scan.sym:=sym;
        scan.found:=false;
        foreachnodestatic(pm_postprocess,subtree,@jt_writescan_cb,@scan);
        result:=scan.found;
      end;


    { scan state for jt_pure_cond }
    type
      pjtpurescan = ^tjtpurescan;
      tjtpurescan = record
        ok    : boolean;
        vars  : array of tabstractvarsym;
        nvars : integer;
      end;

    function jt_purescan_cb(var n : tnode; arg : pointer) : foreachnoderesult;
      var
        p : pjtpurescan;
        sym : tabstractvarsym;
        i : integer;
      begin
        result:=fen_false;
        p:=pjtpurescan(arg);
        { any write/modify anywhere makes the condition impure }
        if ([nf_write,nf_modify]*n.flags)<>[] then
          begin
            p^.ok:=false;
            exit(fen_norecurse_true);
          end;
        case n.nodetype of
          ordconstn,realconstn,niln,
          addn,subn,muln,andn,orn,xorn,
          notn,unaryminusn,
          equaln,unequaln,ltn,lten,gtn,gten:
            result:=fen_false;
          typeconvn:
            { a range/overflow-checked conversion may trap -> not pure }
            if ([cs_check_range,cs_check_overflow]*n.localswitches)<>[] then
              begin
                p^.ok:=false;
                result:=fen_norecurse_true;
              end
            else
              result:=fen_false;
          loadn:
            begin
              sym:=rangeelim_simple_var(n);
              if not assigned(sym) then
                begin
                  p^.ok:=false;
                  result:=fen_norecurse_true;
                end
              else
                begin
                  { record the variable (deduplicated) }
                  for i:=0 to p^.nvars-1 do
                    if p^.vars[i]=sym then
                      begin
                        result:=fen_norecurse_false;
                        exit;
                      end;
                  if p^.nvars>=length(p^.vars) then
                    setlength(p^.vars,4+p^.nvars*2);
                  p^.vars[p^.nvars]:=sym;
                  inc(p^.nvars);
                  result:=fen_norecurse_false;
                end;
            end;
          else
            { calls, derefs, array/field access, inline nodes, etc. -> impure }
            begin
              p^.ok:=false;
              result:=fen_norecurse_true;
            end;
        end;
      end;

    { True if cond is a side-effect-free, call-free, memory-free predicate over
      constants and simple non-aliased variable loads only; on success returns
      in scan.vars the distinct variables it reads. }
    function jt_pure_cond(cond : tnode; out scan : tjtpurescan) : boolean;
      begin
        scan.ok:=true;
        scan.nvars:=0;
        setlength(scan.vars,0);
        result:=false;
        if not assigned(cond) then
          exit;
        foreachnodestatic(pm_postprocess,cond,@jt_purescan_cb,@scan);
        result:=scan.ok;
      end;


    { Decide a condition against the active facts.
      Returns +1 (provably true), 0 (provably false) or -1 (undecided). }
    function jt_decide(cond : tnode; const facts : tjtfactarr) : integer;
      var
        qsym : tabstractvarsym;
        qop : tnodetype;
        qc : tconstexprint;
        qsigned : boolean;
        i : integer;
      begin
        result:=-1;
        if not assigned(cond) then
          exit;
        { comparison-fact reasoning }
        if jt_recognize_cmp(cond,qsym,qop,qc,qsigned) then
          for i:=0 to high(facts) do
            if facts[i].iscmp and (facts[i].sym=qsym) and (facts[i].signed=qsigned) then
              begin
                if jt_all_satisfy(facts[i].op,facts[i].c,qop,qc) then
                  exit(1);
                if jt_all_satisfy(facts[i].op,facts[i].c,jt_negate_relop(qop),qc) then
                  exit(0);
              end;
        { identical-predicate reasoning }
        for i:=0 to high(facts) do
          if not facts[i].iscmp and assigned(facts[i].origcond) and
             cond.isequal(facts[i].origcond) then
            begin
              if facts[i].asserted then
                exit(1)
              else
                exit(0);
            end;
      end;


    procedure jt_walk(var n : tnode; const facts : tjtfactarr; changed : pboolean); forward;

    { Build the fact set that holds inside one branch of a dominating if:
      the inherited facts (still valid, since their variable was proven
      unmodified in the enclosing region) plus, when provable, the new fact
      that <cond> is <assert_true> throughout this branch. }
    function jt_branch_facts(const facts : tjtfactarr; cond, branch : tnode;
                             assert_true : boolean) : tjtfactarr;
      var
        sym : tabstractvarsym;
        op : tnodetype;
        c : tconstexprint;
        signed : boolean;
        scan : tjtpurescan;
        i : integer;
        allunwritten : boolean;
        nf : tjtfact;
      begin
        result:=copy(facts);
        if not assigned(cond) then
          exit;
        { comparison fact: a single variable, decidable by range implication }
        if jt_recognize_cmp(cond,sym,op,c,signed) then
          begin
            if jt_writes_var(branch,sym) then
              exit;   { variable changes in this branch -> not invariant }
            nf.sym:=sym;
            nf.iscmp:=true;
            if assert_true then
              nf.op:=op
            else
              nf.op:=jt_negate_relop(op);
            nf.c:=c;
            nf.signed:=signed;
            nf.origcond:=nil;
            nf.asserted:=true;
            setlength(result,length(result)+1);
            result[high(result)]:=nf;
            exit;
          end;
        { identical-predicate fact: pure condition, no variable written here.
          scan is a managed record (holds a dynamic array); initialize it before
          the out-parameter call so DFA does not flag it as possibly-uninitialized
          at -O4 (which -Sew turns into a self-compile error). }
        scan:=default(tjtpurescan);
        if jt_pure_cond(cond,scan) and (scan.nvars>0) then
          begin
            allunwritten:=true;
            for i:=0 to scan.nvars-1 do
              if jt_writes_var(branch,scan.vars[i]) then
                begin
                  allunwritten:=false;
                  break;
                end;
            if allunwritten then
              begin
                nf.sym:=nil;
                nf.iscmp:=false;
                nf.op:=cond.nodetype;
                nf.signed:=false;
                nf.origcond:=cond;
                nf.asserted:=assert_true;
                setlength(result,length(result)+1);
                result[high(result)]:=nf;
              end;
          end;
      end;


    procedure jt_do_if(var n : tnode; const facts : tjtfactarr; changed : pboolean);
      var
        ifn_ : tifnode;
        d : integer;
        keep : tnode;
        thenfacts, elsefacts : tjtfactarr;
      begin
        ifn_:=tifnode(n);
        d:=jt_decide(ifn_.left,facts);
        if d=1 then
          begin
            { condition known true: thread straight to the then-branch }
            keep:=ifn_.right;
            ifn_.right:=nil;
            if not assigned(keep) then
              begin
                keep:=cnothingnode.create;
                do_firstpass(keep);
              end;
            n.free;
            n:=keep;
            changed^:=true;
            jt_walk(n,facts,changed);
            exit;
          end
        else if d=0 then
          begin
            { condition known false: thread straight to the else-branch }
            keep:=ifn_.t1;
            ifn_.t1:=nil;
            if not assigned(keep) then
              begin
                keep:=cnothingnode.create;
                do_firstpass(keep);
              end;
            n.free;
            n:=keep;
            changed^:=true;
            jt_walk(n,facts,changed);
            exit;
          end;
        { undecided: descend into both branches with the branch-local facts }
        jt_walk(ifn_.left,facts,changed);
        thenfacts:=jt_branch_facts(facts,ifn_.left,ifn_.right,true);
        jt_walk(ifn_.right,thenfacts,changed);
        elsefacts:=jt_branch_facts(facts,ifn_.left,ifn_.t1,false);
        jt_walk(ifn_.t1,elsefacts,changed);
      end;


    function jt_walk_cb(var n : tnode; arg : pointer) : foreachnoderesult;
      var
        env : pjtenv;
      begin
        env:=pjtenv(arg);
        if n.nodetype=ifn then
          begin
            { jt_do_if fully handles this if and its whole subtree (forking the
              facts for its branches), so do not let the generic walk descend }
            jt_do_if(n,env^.facts,env^.changed);
            result:=fen_norecurse_false;
          end
        else
          { any other node inherits the same facts; keep descending }
          result:=fen_false;
      end;

    { Walk subtree n under the given active facts, folding decided re-tests. }
    procedure jt_walk(var n : tnode; const facts : tjtfactarr; changed : pboolean);
      var
        env : tjtenv;
      begin
        if not assigned(n) then
          exit;
        env.facts:=facts;
        env.changed:=changed;
        foreachnodestatic(pm_preprocess,n,@jt_walk_cb,@env);
      end;


    function OptimizeJumpThread(node : tnode) : boolean;
      var
        changed : boolean;
        emptyfacts : tjtfactarr;
      begin
        changed:=false;
        setlength(emptyfacts,0);
        jt_walk(node,emptyfacts,@changed);
        Result:=changed;
      end;

end.

