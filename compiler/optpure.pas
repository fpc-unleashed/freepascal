{
    Interprocedural pure/const function-attribute discovery (-OoPURE)

    Ports the idea of gcc's -fipa-pure-const to FPC.  For each ordinary routine
    compiled in the current unit this pass proves, conservatively, whether the
    routine is

      * "const" : its result depends only on its by-value parameters -- it reads
                  no global/static/threadvar/dereferenced memory and has no side
                  effects, and

      * "pure"  : it may read global memory but never writes it and performs no
                  I/O and no other observable side effect.

    Because a wrong attribute is a miscompile, everything that cannot be proven
    harmless is treated as impure: any write to a global/static/threadvar or
    through a pointer, any I/O, raise, try/except, inline assembler, trapping
    (range/overflow-checked or div/mod) arithmetic, and any call to an
    indirect/virtual/external/method/nested routine or to a routine that is not
    itself proven pure/const.

    The per-routine summary is stored on the tprocdef (transient, not saved to
    the ppu -- a cross-unit / WPO version is a follow-up).  A summary records
    the intrinsic facts of the body plus the list of ordinary routines it calls;
    the actual pure/const verdict is computed on demand with a greatest-fixpoint
    DFS over that call graph, so mutually-recursive SCCs whose only impurity
    would be the recursion itself are still proven.

    This module is free software; see the FPC copying conditions.
}
unit optpure;

{$i fpcdefs.inc}

interface

    uses
      node,symdef;

    { analyse the (final) node tree CODE of routine PD and fill in its
      transient purity summary (pd.pure_analyzed etc.) }
    procedure AnalyzeProcPurity(pd : tprocdef; code : tnode);

    { on-demand verdicts over the summaries collected so far. A routine that has
      not been analysed (e.g. loaded from another unit) is treated as impure. }
    function proc_is_pure(pd : tprocdef) : boolean;
    function proc_is_const(pd : tprocdef) : boolean;

implementation

    uses
      globtype,
      cclasses,
      symbase,symtype,symconst,symsym,symtable,
      nutils,ncal,nld,nmem,ninl,ncnv,
      compinnr;

    type
      ppurescan = ^tpurescan;
      tpurescan = record
        pd : tprocdef;
        impure : boolean;
        readsglobal : boolean;
      end;

    { inline intrinsics that are genuinely side-effect-free, non-trapping value
      computations. Anything not listed here is treated as impure (safe: at
      worst we miss an optimisation). Deliberately excludes length/high/low
      (memory reads), setlength/new/dispose/write/read/inc/dec (side effects),
      etc. }
    function pure_inline(nr : tinlinenumber) : boolean;
      begin
        case nr of
          in_lo_word,in_hi_word,in_lo_long,in_hi_long,in_lo_qword,in_hi_qword,
          in_ord_x,in_chr_byte,
          in_abs_long,in_abs_real,in_sqr_real,in_sqrt_real,in_pi_real:
            result:=true;
          else
            result:=false;
        end;
      end;


    { classify the ultimate base of an l-value: does writing to it write global
      or otherwise externally-observable memory? Returns true if the write is a
      side effect (global/static/threadvar, by-ref parameter, pointer deref, or
      anything not recognised as a plain local), false for a write to a local /
      by-value parameter / simple function result. }
    function lvalue_write_is_side_effect(t : tnode) : boolean;
      var
        sym : tsym;
      begin
        result:=true;
        while assigned(t) do
          case t.nodetype of
            typeconvn:
              t:=ttypeconvnode(t).left;
            subscriptn:
              t:=tsubscriptnode(t).left;
            vecn:
              { a[i]: descend to the base; a deref/global base is caught there,
                a local static array base ends at its loadn }
              t:=tvecnode(t).left;
            derefn:
              exit(true);
            loadn:
              begin
                sym:=tloadnode(t).symtableentry;
                if sym is tstaticvarsym then
                  exit(true)
                else if sym is tparavarsym then
                  begin
                    if (tparavarsym(sym).varspez in [vs_var,vs_out,vs_constref]) and
                       not(vo_is_funcret in tparavarsym(sym).varoptions) then
                      exit(true)
                    else
                      exit(false);
                  end
                else if sym is tlocalvarsym then
                  exit(false)
                else
                  exit(true);
              end;
            else
              exit(true);
          end;
      end;


    { a call to a routine with any of these properties can never be proven
      pure/const and must not even be added to the callee list }
    function procoptions_conflict(pd : tprocdef) : boolean;
      begin
        result:=
          (po_external in pd.procoptions) or
          (po_virtualmethod in pd.procoptions) or
          (po_abstractmethod in pd.procoptions) or
          (po_assembler in pd.procoptions) or
          assigned(pd.struct) or
          (pd.owner.symtabletype=localsymtable);
      end;


    function purescan_node(var n : tnode; arg : pointer) : foreachnoderesult;
      var
        ctx : ppurescan;
        sym : tsym;
        pd : tabstractprocdef;
        iswrite : boolean;
      begin
        result:=fen_true;
        ctx:=ppurescan(arg);
        { once proven impure there is nothing left to discover }
        if ctx^.impure then
          begin
            result:=fen_norecurse_true;
            exit;
          end;
        case n.nodetype of
          asmn,raisen,tryexceptn,tryfinallyn,onn,goton,labeln,addrn:
            ctx^.impure:=true;
          divn,modn:
            { division may trap (div by zero) -> not safe to speculate }
            ctx^.impure:=true;
          addn,subn,muln,unaryminusn,typeconvn,vecn:
            begin
              if ([cs_check_overflow,cs_check_range]*n.localswitches)<>[] then
                ctx^.impure:=true;
              if n.nodetype=vecn then
                ctx^.readsglobal:=true;
            end;
          subscriptn:
            ctx^.readsglobal:=true;
          derefn:
            begin
              if ([nf_write,nf_modify]*n.flags)<>[] then
                ctx^.impure:=true
              else
                ctx^.readsglobal:=true;
            end;
          assignn:
            if lvalue_write_is_side_effect(tassignmentnode(n).left) then
              ctx^.impure:=true;
          inlinen:
            if not pure_inline(tinlinenode(n).inlinenumber) then
              ctx^.impure:=true;
          loadn:
            begin
              sym:=tloadnode(n).symtableentry;
              iswrite:=([nf_write,nf_modify]*n.flags)<>[];
              if sym is tstaticvarsym then
                begin
                  if iswrite then
                    ctx^.impure:=true
                  else
                    ctx^.readsglobal:=true;
                end
              else if sym is tparavarsym then
                begin
                  if (tparavarsym(sym).varspez in [vs_var,vs_out,vs_constref]) and
                     not(vo_is_funcret in tparavarsym(sym).varoptions) then
                    begin
                      if iswrite then
                        ctx^.impure:=true
                      else
                        ctx^.readsglobal:=true;
                    end;
                  { by-value / const-by-value / funcret parameter: local copy }
                end
              else if (sym is tlocalvarsym) or (sym is tconstsym) or
                      (sym is tprocsym) or (sym is ttypesym) then
                { local / true constant / routine address / type: harmless }
              else
                { unknown symbol kind (absolute var, with-field, ...): be safe }
                begin
                  if iswrite then
                    ctx^.impure:=true
                  else
                    ctx^.readsglobal:=true;
                end;
            end;
          calln:
            begin
              pd:=tcallnode(n).procdefinition;
              if not assigned(pd) or not(pd is tprocdef) then
                { indirect / procvar call: unknown target }
                ctx^.impure:=true
              else if assigned(tcallnode(n).methodpointer) then
                { dynamically-dispatched / method-through-pointer call }
                ctx^.impure:=true
              else if (procoptions_conflict(tprocdef(pd))) then
                ctx^.impure:=true
              else
                begin
                  { direct call to an ordinary routine: record the dependency,
                    the fixpoint decides whether it keeps us pure/const }
                  SetLength(ctx^.pd.pure_callees,Length(ctx^.pd.pure_callees)+1);
                  ctx^.pd.pure_callees[High(ctx^.pd.pure_callees)]:=tprocdef(pd);
                end;
            end;
          else
            ;
        end;
        if ctx^.impure then
          result:=fen_norecurse_true;
      end;


    { does the routine's signature/shape make it eligible at all? We restrict
      the first landing to standalone (non-method, non-nested) routines with a
      simple scalar/pointer result and only simple by-value parameters, so that
      the result lives in a local, no by-ref parameter can write caller memory,
      and reading a parameter is a plain local read. }
    function simple_purity_type(def : tdef) : boolean;
      begin
        result:=assigned(def) and (def.typ in [orddef,enumdef,floatdef,pointerdef]);
      end;


    function proc_eligible(pd : tprocdef) : boolean;
      var
        i : longint;
        pv : tparavarsym;
      begin
        result:=false;
        if procoptions_conflict(pd) then
          exit;
        if not simple_purity_type(pd.returndef) then
          exit;
        for i:=0 to pd.paras.count-1 do
          begin
            pv:=tparavarsym(pd.paras[i]);
            if vo_is_hidden_para in pv.varoptions then
              exit;
            if not(pv.varspez in [vs_value,vs_const]) then
              exit;
            if not simple_purity_type(pv.vardef) then
              exit;
          end;
        result:=true;
      end;


    procedure AnalyzeProcPurity(pd : tprocdef; code : tnode);
      var
        ctx : tpurescan;
      begin
        if not assigned(pd) or not assigned(code) then
          exit;
        pd.pure_callees:=nil;
        pd.pure_reads_global:=false;
        pd.pure_qtoken:=0;
        pd.pure_qresult:=0;
        if not proc_eligible(pd) then
          begin
            pd.pure_intrinsic_impure:=true;
            pd.pure_analyzed:=true;
            exit;
          end;
        ctx.pd:=pd;
        ctx.impure:=false;
        ctx.readsglobal:=false;
        foreachnodestatic(pm_postprocess,code,@purescan_node,@ctx);
        pd.pure_intrinsic_impure:=ctx.impure;
        pd.pure_reads_global:=ctx.readsglobal;
        pd.pure_analyzed:=true;
      end;


    { ---- on-demand greatest-fixpoint verdict ---------------------------------

      Query semantics (const, and analogously pure):
          const(pd) = pd analysed
                      and not pd.pure_intrinsic_impure
                      and not pd.pure_reads_global
                      and const(c) for every callee c

      A per-query token distinguishes results/marks of the current query from
      stale ones. pure_qresult: 0 = currently on the DFS stack (assume pure
      optimistically to break cycles), 1 = decided pure/const, 2 = decided
      impure. False strictly dominates and short-circuits, so a member of an SCC
      is only ever decided pure/const when the whole SCC genuinely is. }

    var
      pure_query_token : cardinal = 0;

    function dfs_pure(pd : tprocdef; token : cardinal; wantconst : boolean) : boolean;
      var
        i : longint;
        r : boolean;
      begin
        if not assigned(pd) or not pd.pure_analyzed then
          exit(false);
        if pd.pure_qtoken=token then
          begin
            case pd.pure_qresult of
              1: exit(true);
              2: exit(false);
              else exit(true); { on stack: optimistic }
            end;
          end;
        pd.pure_qtoken:=token;
        pd.pure_qresult:=0; { visiting }
        if pd.pure_intrinsic_impure or (wantconst and pd.pure_reads_global) then
          begin
            pd.pure_qresult:=2;
            exit(false);
          end;
        r:=true;
        for i:=0 to High(pd.pure_callees) do
          if not dfs_pure(pd.pure_callees[i],token,wantconst) then
            begin
              r:=false;
              break;
            end;
        if r then
          pd.pure_qresult:=1
        else
          pd.pure_qresult:=2;
        result:=r;
      end;


    function proc_is_pure(pd : tprocdef) : boolean;
      begin
        inc(pure_query_token);
        result:=dfs_pure(pd,pure_query_token,false);
      end;


    function proc_is_const(pd : tprocdef) : boolean;
      begin
        inc(pure_query_token);
        result:=dfs_pure(pd,pure_query_token,true);
      end;

end.
