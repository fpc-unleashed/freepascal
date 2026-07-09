{
    Dead store elimination

    Copyright (c) 2005-2012 by Jeppe Johansen and Florian Klaempfl

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
unit optdeadstore;

{$i fpcdefs.inc}

{ $define DEBUG_DEADSTORE}
{ $define EXTDEBUG_DEADSTORE}

  interface

    uses
      node;

    function do_optdeadstoreelim(var rootnode : tnode;out changed: boolean) : tnode;

  implementation

    uses
      verbose,globtype,cdynset,globals,
      procinfo,pass_1,
      nutils,
      nbas,nld,nmem,ncal,
      defutil,
      optbase,optpure,
      symtype,symdef,symsym,symconst;


    function deadstoreelim(var n: tnode; arg: pointer): foreachnoderesult;
      var
        a: tassignmentnode;
        redundant: boolean;
      begin
        result:=fen_true;
        if (n.nodetype=statementn) and
           assigned(tstatementnode(n).statement) then
          begin
            if tstatementnode(n).statement.nodetype=assignn then
              begin
                a:=tassignmentnode(tstatementnode(n).statement);

                { we need to have dfa for the node }
                if assigned(a.left.optinfo) and
                   { node must be either a local or parameter load node }
                   (a.left.nodetype=loadn) and
                   { its address cannot have escaped the current routine }
                   not(tabstractvarsym(tloadnode(a.left).symtableentry).addr_taken) and
                   ((
                     (tloadnode(a.left).symtableentry.typ=localvarsym) and
                     (tloadnode(a.left).symtable=current_procinfo.procdef.localst)) or
                    ((tloadnode(a.left).symtableentry.typ=paravarsym) and
                     (tloadnode(a.left).symtable=current_procinfo.procdef.parast) and
                     (tparavarsym(tloadnode(a.left).symtableentry).varspez in [vs_const,vs_value])) or
                    ((tloadnode(a.left).symtableentry.typ=staticvarsym) and
                     (tloadnode(a.left).symtable.symtabletype=staticsymtable) and
                     (current_procinfo.procdef.proctypeoption<>potype_unitinit) and
                     not(vsa_different_scope in tstaticvarsym(tloadnode(a.left).symtableentry).varsymaccess)
                    )
                   ) and
                    ((a.right.nodetype in [niln,stringconstn,pointerconstn,setconstn,guidconstn]) or
                     ((a.right.nodetype=ordconstn) and not(cs_check_range in current_settings.localswitches)) or
                     ((a.right.nodetype=realconstn) and not(cs_ieee_errors in current_settings.localswitches)) or
                    ((cs_opt_dead_values in current_settings.optimizerswitches) and not(might_have_sideeffects(a.right,[mhs_exceptions])))
                   ) then
                  begin
                    redundant:=not(assigned(a.successor)) or not(DynSetIn(a.successor.optinfo^.life,a.left.optinfo^.index));

                    if redundant then
                      begin
{$ifdef DEBUG_DEADSTORE}
                        writeln('************************** Redundant write *********************************');
                        printnode(a);
                        writeln('****************************************************************************');
{$endif DEBUG_DEADSTORE}
                        pboolean(arg)^:=true;

                        tstatementnode(n).statement.free;

                        tstatementnode(n).statement:=cnothingnode.create;
                        { do not run firstpass on n here, as it will remove the statement node
                          and this will make foreachnodestatic process the wrong nodes as the current statement
                          node will disappear }
                      end
                  end;
              end;
          end;
      end;


    { ------------------------------------------------------------------------
      Extended dead-store elimination for record-field and static-array-element
      stores.

      The stock pass above only handles a store whose LHS is a whole-variable
      loadn (its redundancy is decided from DFA whole-variable liveness). DFA
      tracks liveness per variable, which is too coarse to reason about an
      individual field/element, so this second pass does a conservative,
      straight-line, memory-location-precise scan instead.

      Within a run of consecutive statements it keeps a "pending" set of stores
      to compile-time-known slots (base variable + constant field/element path).
      A pending store is KILLED (proven dead) only when a LATER store overwrites
      the *exact same location* (compared structurally with tnode.isequal, which
      matches the base sym, every field vs and every constant array index) with
      no intervening statement that could observe it.

      Soundness rules (deliberately over-conservative):
      * base must be a non-address-taken local / value-or-const parameter /
        non-different-scope static var of the current routine (same predicate as
        the stock pass) -- so two distinct bases can never overlap in memory;
      * the location path may only contain record-field subscripts and
        constant-ordinal indexes into genuine, non-packed, non-special (not
        dynamic / open / variant / array-of-const) static arrays -- anything
        pointer-backed (p^, dynamic array, open array) is rejected because it
        could alias a different base variable that this base-only reasoning
        cannot see (e.g. f(x,x) passing the same buffer twice);
      * managed/ref-counted slot types are skipped entirely (the store has
        finalization side effects);
      * the RHS must be free of exception/range/overflow side effects
        (might_have_sideeffects with mhs_exceptions) and must contain no call,
        pointer deref or asm node;
      * any read of the base variable between the two stores keeps the earlier
        store (invalidation is per base variable, i.e. conservative);
      * any call, pointer deref, asm block, compound assignment, control-flow
        construct or otherwise unclassified statement flushes the whole pending
        set (acts as a barrier -- so "no intervening call / no try-except
        boundary" is guaranteed structurally).
      ------------------------------------------------------------------------ }

    type
      treadbaseinfo = record
        sym   : tsym;
        found : boolean;
      end;
      preadbaseinfo = ^treadbaseinfo;

    { foreachnode callback: sets found if the rvalue tree loads sym }
    function el_checkreadsbase(var n: tnode; arg: pointer): foreachnoderesult;
      begin
        result:=fen_true;
        if (n.nodetype=loadn) and
           (tloadnode(n).symtableentry=preadbaseinfo(arg)^.sym) then
          begin
            preadbaseinfo(arg)^.found:=true;
            result:=fen_norecurse_true;
          end;
      end;

    { foreachnode callback: sets flag if the tree contains a node that may read
      hidden/aliased memory (call, pointer deref, inline asm) }
    function el_checkhazard(var n: tnode; arg: pointer): foreachnoderesult;
      begin
        result:=fen_true;
        if n.nodetype in [calln,derefn,asmn] then
          begin
            pboolean(arg)^:=true;
            result:=fen_norecurse_true;
          end;
      end;

    { returns the root load node of a "simple stack location" path (chain of
      record-field subscripts and constant-index static-array element accesses),
      or nil if the path involves anything that could alias another base }
    function el_simple_stackloc_base(n: tnode): tloadnode;
      begin
        result:=nil;
        while assigned(n) do
          case n.nodetype of
            loadn:
              begin
                result:=tloadnode(n);
                exit;
              end;
            subscriptn:
              begin
                if not assigned(tsubscriptnode(n).left.resultdef) or
                   is_packed_record_or_object(tsubscriptnode(n).left.resultdef) then
                  exit;
                n:=tsubscriptnode(n).left;
              end;
            vecn:
              begin
                { vnf_memindex/vnf_memseg change the addressing mode (inline-asm
                  / absolute references); vnf_callunique is inert for a normal
                  static array (only strings/dynarrays emit the unique call, and
                  those are excluded by is_normal_array below) }
                if ((tvecnode(n).vecnodeflags*[vnf_memindex,vnf_memseg])<>[]) or
                   (tvecnode(n).right.nodetype<>ordconstn) or
                   not assigned(tvecnode(n).left.resultdef) or
                   not is_normal_array(tvecnode(n).left.resultdef) or
                   is_packed_array(tvecnode(n).left.resultdef) then
                  exit;
                n:=tvecnode(n).left;
              end;
            else
              exit;
          end;
      end;

    { same base predicate the stock pass uses for whole-variable stores }
    function el_qualifying_base(l: tloadnode): boolean;
      begin
        result:=
          not(tabstractvarsym(l.symtableentry).addr_taken) and
          (
            ((l.symtableentry.typ=localvarsym) and
             (l.symtable=current_procinfo.procdef.localst)) or
            ((l.symtableentry.typ=paravarsym) and
             (l.symtable=current_procinfo.procdef.parast) and
             (tparavarsym(l.symtableentry).varspez in [vs_const,vs_value])) or
            ((l.symtableentry.typ=staticvarsym) and
             (l.symtable.symtabletype=staticsymtable) and
             (current_procinfo.procdef.proctypeoption<>potype_unitinit) and
             not(vsa_different_scope in tstaticvarsym(l.symtableentry).varsymaccess))
          );
      end;

    { --- pure/const call barrier relaxation (-OoPURE consumer) --------------

      The field-store scan above treats every call as a hard barrier: it may
      read the pending store's memory (keeping it live) or write memory (an
      aliasing effect). A call whose target -OoPURE proved PURE or CONST is far
      weaker and need not flush the whole pending set:

        * a CONST routine reads and writes NO memory at all -- it can neither
          observe nor clobber a pending store, so it is a complete non-barrier
          (only its argument expressions, scanned normally, perform reads);

        * a PURE routine writes no memory but MAY read global/heap state, so it
          is a potential *reader*: a pending store to a globally reachable slot
          (a static var, or a by-reference const parameter) could be observed
          and must be kept live, but a store to a non-address-taken local or a
          by-value parameter is invisible to any callee (no pointer to it can
          exist) and therefore survives the pure call.

      Indirect / procvar / virtual / aggregate-returning calls stay full
      barriers, as do deref and asm nodes. }

    type
      tcallkind = (elc_barrier, elc_pure, elc_const);

    function el_classify_call(cn: tcallnode): tcallkind;
      var
        pd : tprocdef;
      begin
        result:=elc_barrier;
        if not(cs_opt_pure in current_settings.optimizerswitches) then
          exit;
        { resolved direct call only (excludes indirect / procvar targets) }
        if not assigned(cn.procdefinition) or not(cn.procdefinition is tprocdef) then
          exit;
        pd:=tprocdef(cn.procdefinition);
        { a method call must dispatch to a statically known body }
        if assigned(cn.methodpointer) and
           ((po_virtualmethod in pd.procoptions) or
            (po_abstractmethod in pd.procoptions)) then
          exit;
        { aggregate return machinery performs hidden stores -> stay a barrier }
        if assigned(cn.funcretnode) or assigned(cn.callinitblock) or
           assigned(cn.callcleanupblock) then
          exit;
        if proc_is_const(pd) then
          result:=elc_const
        else if proc_is_pure(pd) then
          result:=elc_pure;
      end;

    { true if a pure callee could read this pending-store base's memory. The
      base is guaranteed non-address-taken (el_qualifying_base); a local var or
      a by-value parameter thus cannot be named by any callee, while a static
      var is global memory and a by-reference const parameter aliases caller
      storage the callee may have been handed. }
    function el_base_globally_reachable(s: tsym): boolean;
      begin
        result:=true;
        case s.typ of
          localvarsym:
            result:=false;
          paravarsym:
            result:=(tparavarsym(s).varspez<>vs_value);
          else
            ; { staticvarsym / anything else: assume reachable }
        end;
      end;

    type
      thazinfo = record
        barrier  : boolean; { deref / asm / impure call -> hard flush }
        purecall : boolean; { a proven-PURE (global-reading) call was seen }
      end;
      phazinfo = ^thazinfo;

    { scan a tree for memory hazards, treating a proven pure/const call as a
      non-barrier (recursing into its arguments so a nested hazard is still
      caught) and recording whether any pure (global-reading) call occurred. }
    function el_haz_scan(var n: tnode; arg: pointer): foreachnoderesult;
      begin
        result:=fen_true;
        case n.nodetype of
          derefn,asmn:
            begin
              phazinfo(arg)^.barrier:=true;
              result:=fen_norecurse_true;
            end;
          calln:
            case el_classify_call(tcallnode(n)) of
              elc_barrier:
                begin
                  phazinfo(arg)^.barrier:=true;
                  result:=fen_norecurse_true;
                end;
              elc_pure:
                phazinfo(arg)^.purecall:=true;
              elc_const:
                ;
            end;
          else
            ;
        end;
      end;

    procedure el_fieldstore_block(firststmt: tnode; var changed: boolean);
      type
        tpendrec = record
          container : tstatementnode;
          a         : tassignmentnode;
          base      : tsym;
        end;
      var
        pend  : array of tpendrec;
        npend : longint;

      procedure pend_flush;
        begin
          npend:=0;
        end;

      procedure pend_remove(idx: longint);
        begin
          pend[idx]:=pend[npend-1];
          dec(npend);
        end;

      procedure pend_add(c: tstatementnode; a: tassignmentnode; b: tsym);
        begin
          if npend>=length(pend) then
            setlength(pend,(npend+1)*2);
          pend[npend].container:=c;
          pend[npend].a:=a;
          pend[npend].base:=b;
          inc(npend);
        end;

      { drop pending stores whose base variable is read anywhere in rvalue tree r }
      procedure invalidate_reads(r: tnode);
        var
          i    : longint;
          info : treadbaseinfo;
          tmp  : tnode;
        begin
          i:=0;
          while i<npend do
            begin
              info.sym:=pend[i].base;
              info.found:=false;
              tmp:=r;
              foreachnodestatic(tmp,@el_checkreadsbase,@info);
              if info.found then
                pend_remove(i)
              else
                inc(i);
            end;
        end;

      { drop pending stores a pure call may observe (globally reachable bases) }
      procedure invalidate_globals;
        var
          i : longint;
        begin
          i:=0;
          while i<npend do
            if el_base_globally_reachable(pend[i].base) then
              pend_remove(i)
            else
              inc(i);
        end;

      { apply a relaxed (pure/const-aware) barrier for a tree that is not a
        DSE store candidate: an impure hazard flushes everything, otherwise the
        syntactic reads invalidate matching pending stores and a pure call
        additionally invalidates every globally reachable pending store. }
      procedure apply_relaxed_barrier(tree: tnode);
        var
          hz  : thazinfo;
          tmp : tnode;
        begin
          hz.barrier:=false;
          hz.purecall:=false;
          tmp:=tree;
          foreachnodestatic(tmp,@el_haz_scan,@hz);
          if hz.barrier then
            pend_flush
          else
            begin
              invalidate_reads(tree);
              if hz.purecall then
                invalidate_globals;
            end;
        end;

      procedure handle_stmt(sn: tstatementnode);
        var
          stmt    : tnode;
          a       : tassignmentnode;
          lhsbase : tloadnode;
          iscand  : boolean;
          haz     : boolean;
          i       : longint;
          tmp     : tnode;
        begin
          stmt:=sn.statement;
          if not assigned(stmt) then
            exit;
          case stmt.nodetype of
            nothingn:
              ; { does nothing, keep pending }
            blockn:
              begin
                pend_flush;
                if assigned(tblocknode(stmt).left) then
                  el_fieldstore_block(tblocknode(stmt).left,changed);
                pend_flush;
              end;
            assignn:
              begin
                a:=tassignmentnode(stmt);
                lhsbase:=nil;
                iscand:=false;
                if (a.assigntype=at_normal) and
                   (a.assignmentnodeflags=[]) and
                   (a.left.nodetype in [subscriptn,vecn]) and
                   assigned(a.left.resultdef) and
                   not is_managed_type(a.left.resultdef) then
                  begin
                    lhsbase:=el_simple_stackloc_base(a.left);
                    if assigned(lhsbase) and
                       el_qualifying_base(lhsbase) and
                       not might_have_sideeffects(a.right,[mhs_exceptions]) then
                      begin
                        haz:=false;
                        tmp:=a.right;
                        foreachnodestatic(tmp,@el_checkhazard,@haz);
                        iscand:=not haz;
                      end;
                  end;
                if iscand then
                  begin
                    { reads = rhs only; the constant-index LHS path performs no
                      value reads of any base }
                    invalidate_reads(a.right);
                    { kill earlier stores to the exact same location }
                    i:=0;
                    while i<npend do
                      begin
                        if (pend[i].base=lhsbase.symtableentry) and
                           pend[i].a.left.isequal(a.left) then
                          begin
{$ifdef DEBUG_DEADSTORE}
                            writeln('*************** Redundant field/element write *****************');
                            printnode(pend[i].a);
                            writeln('***************************************************************');
{$endif DEBUG_DEADSTORE}
                            pend[i].container.statement.free;
                            pend[i].container.statement:=cnothingnode.create;
                            changed:=true;
                            pend_remove(i);
                          end
                        else
                          inc(i);
                      end;
                    pend_add(sn,a,lhsbase.symtableentry);
                  end
                else
                  begin
                    { non-candidate assignment: scan the whole thing (incl. LHS
                      base loads and compound-op implicit reads). An impure
                      hazard is a barrier; a proven pure/const call is relaxed
                      per apply_relaxed_barrier; otherwise treat as reads of the
                      pending bases. }
                    apply_relaxed_barrier(a);
                  end;
              end;
            calln:
              { a bare call statement: full barrier unless -OoPURE proved the
                target pure/const, in which case only its reads matter }
              apply_relaxed_barrier(stmt);
            else
              pend_flush; { any other statement is a conservative barrier }
          end;
        end;

      var
        sn : tstatementnode;
      begin
        pend:=nil;
        npend:=0;
        sn:=tstatementnode(firststmt);
        while assigned(sn) and (sn.nodetype=statementn) do
          begin
            handle_stmt(sn);
            sn:=tstatementnode(sn.next);
          end;
        setlength(pend,0);
      end;


    function do_optdeadstoreelim(var rootnode: tnode;out changed: boolean): tnode;
      begin
        changed:=false;
{$ifdef EXTDEBUG_DEADSTORE}
        writeln('******************* Tree before deadstore elimination **********************');
        printnode(rootnode);
        writeln('****************************************************************************');
{$endif EXTDEBUG_DEADSTORE}
        if not(pi_dfaavailable in current_procinfo.flags) then
          internalerror(2013110201);
        if not current_procinfo.has_nestedprocs then
          begin
            foreachnodestatic(pm_postprocess, rootnode, @deadstoreelim, @changed);
            { extended pass: record-field and static-array-element stores }
            if rootnode.nodetype=blockn then
              el_fieldstore_block(tblocknode(rootnode).left,changed);
          end;
{$ifdef DEBUG_DEADSTORE}
        if changed then
          begin
            writeln('******************** Tree after deadstore elimination **********************');
            printnode(rootnode);
            writeln('****************************************************************************');
          end;
{$endif DEBUG_DEADSTORE}
        result:=rootnode;
      end;

end.

