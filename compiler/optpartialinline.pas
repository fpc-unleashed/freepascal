{
    Partial inlining / function splitting (-OoPARTIALINLINE)

    Ports the idea of gcc's -fpartial-inlining (gcc/ipa-split.cc) to FPC.

    A routine that begins with a cheap early-exit guard followed by an expensive
    body -- the classic

        procedure Foo(...);
        begin
          if <cheap condition> then exit;   // (or exit(value) for a function)
          ...heavy work...
        end;

    -- is split into two routines:

      * an out-of-line "body" routine that keeps the *entire* original code
        (guard included) and simply gets a fresh, private procsym; and

      * a tiny inlinable "header" routine that takes over the original procsym
        (so callers resolve to it) and whose body is just

            if <cheap condition> then exit[(value)];   // a copy of the guard
            Body(...);                                  // forward the params

        marked `inline`.

    The existing inliner then inlines the header at every call site, so the
    common guarded-exit path pays no call at all, while the cold body stays a
    single out-of-line copy.

    Correctness (why this is always a sound rewrite): the body routine is the
    *unmodified* original, so on its own it is trivially correct.  The header is
    equivalent to the original because
      - guard true  : the header runs the (copied) guard branch, which always
                      exits, and never calls the body -> identical to the
                      original taking the guard;
      - guard false : the header calls the body, whose own guard is again false
                      -> identical to the original falling through to the body.
    The guard condition is required to be side-effect free, so re-evaluating it
    inside the body on the cold path changes nothing observable, and the guard
    branch's effects happen exactly once (only one of header/body ever runs it).

    This is deliberately conservative -- correctness over coverage.  This first
    landing splits only standalone (non-method, non-nested, non-generic)
    PROCEDURES (void return) with simple by-value scalar/pointer/class parameters
    and a single leading guard whose then-branch always exits.  Routines with
    exception handlers, inline assembler, labels, gotos, nested routines,
    varargs, open arrays or threadvar access, inherited calls, and routines that
    are already inline or that have a separate forward/interface declaration are
    skipped.

    Functions (non-void return) are intentionally NOT split yet: splitting them
    is sound in isolation, but when the tiny header is inlined at a call site the
    inliner can route the guard arm's exit(value) and the tail's result
    assignment to different result locations (funcret temp in memory vs. a return
    register), giving a wrong value on one arm.  A function-safe header shape is
    a follow-up.

    Opt-in via -OoPARTIALINLINE (NOT part of -O4 defaults).

    This module is free software; see the FPC copying conditions.
}
unit optpartialinline;

{$i fpcdefs.inc}

interface

    uses
      globtype,node,symdef;

    { If PD (with final body CODE and analysis flags PIFLAGS / HASNESTED) is a
      splittable partial-inline candidate, stash a private copy of its leading
      guard and return true.  Must be called on the final node tree *before* it
      is transformed or freed. }
    function partialinline_candidate(pd : tprocdef; code : tnode;
      piflags : tprocinfoflags; hasnested : boolean) : boolean;

    { After the body routine PD has been fully compiled, materialise the inline
      header procdef: move PD to a private procsym, create a fresh header
      procdef under PD's original procsym, and build its (still untypechecked)
      node tree into HEADERCODE.  Returns the header procdef or nil.  Only valid
      when the immediately preceding partialinline_candidate(PD,...) returned
      true. }
    function partialinline_make_header(pd : tprocdef; out headercode : tnode) : tprocdef;

implementation

    uses
      cclasses,
      symconst,symbase,symtype,symsym,symtable,
      defutil,
      nbas,nld,ncal,nflw,ninl,nutils,
      compinnr,
      symcreat;

    { ---- pending state ------------------------------------------------------
      Top-level routines are compiled one at a time, so a single pending slot
      linking the "candidate" and "make_header" phases is sufficient (nested
      routines are never candidates). }
    var
      pending_pd    : tprocdef = nil;
      pending_guard : tnode = nil;   { deep copy of the leading if-guard, still
                                       referencing PD's own paravarsyms }

    { -------- eligibility of the signature ---------------------------------- }

    function simple_split_type(def : tdef; allowvoid : boolean) : boolean;
      begin
        result:=false;
        if not assigned(def) then
          exit;
        if is_void(def) then
          begin
            result:=allowvoid;
            exit;
          end;
        if is_managed_type(def) then
          exit;
        result:=(def.typ in [orddef,enumdef,floatdef,pointerdef,classrefdef]) or
                is_class(def);
      end;


    function proc_eligible(pd : tprocdef) : boolean;
      var
        i : longint;
        pv : tparavarsym;
      begin
        result:=false;
        { standalone ordinary procedure only. NOTE: functions (non-void return)
          are deliberately excluded in this first landing. Splitting them is
          sound in isolation, but when the tiny header is inlined at a call site
          the inliner can route the guard arm's exit(value) and the tail's
          "result := Body(...)" to different result locations (the funcret temp
          in memory vs. a return register), yielding a wrong value on one arm.
          Supporting functions needs a header shape the inliner funnels through a
          single result location -- a follow-up. }
        if pd.proctypeoption<>potype_procedure then
          exit;
        if not is_void(pd.returndef) then
          exit;
        if assigned(pd.struct) then
          exit;
        if pd.owner.symtabletype=localsymtable then
          exit;
        if pd.parast.symtablelevel>normal_function_level then
          exit;
        if [df_generic,df_specialization]*pd.defoptions<>[] then
          exit;
        { skip anything whose calling / visibility contract we must not touch }
        if ([po_external,po_virtualmethod,po_abstractmethod,po_assembler,
             po_exports,po_interrupt,po_inline,po_noinline]*pd.procoptions)<>[] then
          exit;
        { a separate forward / interface declaration means other, earlier-parsed
          call sites may already be bound to this procdef, and (for interface
          routines) external units link to its mangled name -- skip }
        if not assigned(pd.procsym) or (pd.procsym.typ<>procsym) then
          exit;
        if tprocsym(pd.procsym).ProcdefList.Count<>1 then
          exit;
        { result type must be a simple register-returned value (or void) }
        if not simple_split_type(pd.returndef,true) then
          exit;
        for i:=0 to pd.paras.count-1 do
          begin
            pv:=tparavarsym(pd.paras[i]);
            if vo_is_hidden_para in pv.varoptions then
              exit;
            if not(pv.varspez in [vs_value,vs_const]) then
              exit;
            if not simple_split_type(pv.vardef,false) then
              exit;
          end;
        result:=true;
      end;

    { -------- cheapness of the guard ---------------------------------------- }

    type
      pscanok = ^tscanok;
      tscanok = record
        ok : boolean;
      end;

    { returns true if SYM ultimately denotes threadvar-backed storage }
    function sym_is_threadvar(sym : tsym) : boolean;
      begin
        result:=false;
        if sym is tstaticvarsym then
          result:=vo_is_thread_var in tstaticvarsym(sym).varoptions
        else if sym is tabsolutevarsym then
          { be conservative: absolute-to-something we cannot cheaply classify }
          result:=false;
      end;

    { side-effect-free, non-trapping inline intrinsics that may appear in a
      guard condition (e.g. Assigned, lo/hi, ord).  Everything else is rejected. }
    function pure_guard_inline(nr : tinlinenumber) : boolean;
      begin
        case nr of
          in_assigned_x,
          in_lo_word,in_hi_word,in_lo_long,in_hi_long,in_lo_qword,in_hi_qword,
          in_ord_x,in_chr_byte,
          in_abs_long,in_abs_real,in_sqr_real,in_sqrt_real,in_pi_real:
            result:=true;
          else
            result:=false;
        end;
      end;

    { the guard *condition* must be a pure, side-effect-free, non-trapping value
      computation: no calls, no assignments, no side-effecting intrinsics, no
      control flow, no threadvar reads }
    function scan_cond(var n : tnode; arg : pointer) : foreachnoderesult;
      var
        ctx : pscanok;
      begin
        result:=fen_true;
        ctx:=pscanok(arg);
        case n.nodetype of
          calln,assignn,asmn,raisen,
          tryexceptn,tryfinallyn,onn,goton,labeln,
          whilerepeatn,forn,casen,ifn,addrn:
            ctx^.ok:=false;
          inlinen:
            if not pure_guard_inline(tinlinenode(n).inlinenumber) then
              ctx^.ok:=false;
          loadn:
            if sym_is_threadvar(tloadnode(n).symtableentry) then
              ctx^.ok:=false;
          else
            ;
        end;
        if not ctx^.ok then
          result:=fen_norecurse_true;
      end;

    { the whole body must be free of exception handling, inline assembler,
      labels and gotos -- these are set as procinfo flags only during firstpass
      (which has not run yet when we decide), so scan the tree directly }
    function scan_body_unsafe(var n : tnode; arg : pointer) : foreachnoderesult;
      var
        ctx : pscanok;
      begin
        result:=fen_true;
        ctx:=pscanok(arg);
        case n.nodetype of
          asmn,tryexceptn,tryfinallyn,onn,labeln,goton,raisen:
            ctx^.ok:=false;
          else
            ;
        end;
        if not ctx^.ok then
          result:=fen_norecurse_true;
      end;


    function body_is_safe(code : tnode) : boolean;
      var
        ctx : tscanok;
      begin
        ctx.ok:=true;
        foreachnodestatic(pm_postprocess,code,@scan_body_unsafe,@ctx);
        result:=ctx.ok;
      end;

    { the guard *then-branch* may have side effects (they run exactly once), but
      must be call-free, straight-line code (so it always reaches its exit) }
    function scan_branch(var n : tnode; arg : pointer) : foreachnoderesult;
      var
        ctx : pscanok;
      begin
        result:=fen_true;
        ctx:=pscanok(arg);
        case n.nodetype of
          calln,asmn,raisen,
          tryexceptn,tryfinallyn,onn,goton,labeln,
          whilerepeatn,forn,casen,ifn,addrn:
            ctx^.ok:=false;
          inlinen:
            if not pure_guard_inline(tinlinenode(n).inlinenumber) then
              ctx^.ok:=false;
          loadn:
            if sym_is_threadvar(tloadnode(n).symtableentry) then
              ctx^.ok:=false;
          else
            ;
        end;
        if not ctx^.ok then
          result:=fen_norecurse_true;
      end;


    function last_effect_is_exit(n : tnode) : boolean;
      var
        st : tstatementnode;
      begin
        result:=false;
        if not assigned(n) then
          exit;
        case n.nodetype of
          exitn:
            result:=true;
          statementn:
            result:=last_effect_is_exit(tstatementnode(n).left);
          blockn:
            begin
              st:=tstatementnode(tblocknode(n).left);
              if not assigned(st) then
                exit;
              while assigned(st.right) do
                st:=tstatementnode(st.right);
              result:=last_effect_is_exit(st.left);
            end;
          else
            ;
        end;
      end;


    function guard_is_cheap(ifn : tifnode) : boolean;
      var
        ctx : tscanok;
        cond,thenbranch : tnode;
      begin
        result:=false;
        { shape: if COND then THEN ; no else }
        if assigned(ifn.t1) then
          exit;
        cond:=ifn.left;
        thenbranch:=ifn.right;
        if not assigned(cond) or not assigned(thenbranch) then
          exit;
        { the then-branch must be guaranteed to exit the routine }
        if not last_effect_is_exit(thenbranch) then
          exit;
        { keep the header tiny (it is duplicated at every call site) }
        if node_count(ifn,64)>=64 then
          exit;
        ctx.ok:=true;
        foreachnodestatic(pm_postprocess,cond,@scan_cond,@ctx);
        if not ctx.ok then
          exit;
        ctx.ok:=true;
        foreachnodestatic(pm_postprocess,thenbranch,@scan_branch,@ctx);
        if not ctx.ok then
          exit;
        result:=true;
      end;

    { -------- candidate detection ------------------------------------------ }

    function leading_guard(code : tnode) : tifnode;
      var
        firststmt : tnode;
      begin
        result:=nil;
        if not assigned(code) or (code.nodetype<>blockn) then
          exit;
        firststmt:=tblocknode(code).left;
        if not assigned(firststmt) or (firststmt.nodetype<>statementn) then
          exit;
        { there must be *something* after the guard to make splitting worthwhile }
        if not assigned(tstatementnode(firststmt).right) then
          exit;
        if not assigned(tstatementnode(firststmt).left) or
           (tstatementnode(firststmt).left.nodetype<>ifn) then
          exit;
        result:=tifnode(tstatementnode(firststmt).left);
      end;


    function partialinline_candidate(pd : tprocdef; code : tnode;
      piflags : tprocinfoflags; hasnested : boolean) : boolean;
      var
        ifn : tifnode;
      begin
        result:=false;
        pending_pd:=nil;
        pending_guard:=nil;
        if not assigned(pd) or not assigned(code) then
          exit;
        if hasnested then
          exit;
        { any of these body properties make the split unsafe or pointless }
        if (piflags*[pi_has_assembler_block,pi_is_assembler,pi_uses_exceptions,
             pi_has_label,pi_has_global_goto,pi_has_inherited,
             pi_calls_c_varargs,pi_has_open_array_parameter,
             pi_uses_threadvar])<>[] then
          exit;
        if not proc_eligible(pd) then
          exit;
        if not body_is_safe(code) then
          exit;
        ifn:=leading_guard(code);
        if not assigned(ifn) then
          exit;
        if not guard_is_cheap(ifn) then
          exit;
        { stash a private, deep copy of the guard for the header }
        pending_pd:=pd;
        pending_guard:=ifn.getcopy;
        result:=true;
      end;

    { -------- header materialisation --------------------------------------- }

    type
      premap = ^tremap;
      tremap = record
        oldpd,newpd : tprocdef;
      end;

    { find the visible (non-hidden) parameter of PD at visible-index IDX }
    function nth_visible_para(pd : tprocdef; idx : longint) : tparavarsym;
      var
        i,vis : longint;
        pv : tparavarsym;
      begin
        result:=nil;
        vis:=0;
        for i:=0 to pd.paras.count-1 do
          begin
            pv:=tparavarsym(pd.paras[i]);
            if vo_is_hidden_para in pv.varoptions then
              continue;
            if vis=idx then
              exit(pv);
            inc(vis);
          end;
      end;


    { visible-index of paravarsym SYM within PD, or -1 }
    function visible_index_of(pd : tprocdef; sym : tsym) : longint;
      var
        i,vis : longint;
        pv : tparavarsym;
      begin
        result:=-1;
        vis:=0;
        for i:=0 to pd.paras.count-1 do
          begin
            pv:=tparavarsym(pd.paras[i]);
            if vo_is_hidden_para in pv.varoptions then
              continue;
            if tsym(pv)=sym then
              exit(vis);
            inc(vis);
          end;
      end;


    { Replace every copied exit node with a freshly-created one (stealing its,
      already param-remapped, value subtree). The copies carry a resultdef and a
      funcret binding from when they were type-checked inside the body; a fresh
      exit node is re-analysed in the header's context, so its result assignment
      targets the header's funcret and survives being inlined at call sites. }
    function rebuild_exit(var n : tnode; arg : pointer) : foreachnoderesult;
      var
        old : texitnode;
      begin
        result:=fen_true;
        if n.nodetype<>exitn then
          exit;
        old:=texitnode(n);
        n:=cexitnode.create(old.left);
        old.left:=nil;
        old.free;
      end;


    function remap_load(var n : tnode; arg : pointer) : foreachnoderesult;
      var
        ctx : premap;
        idx : longint;
        newpv : tparavarsym;
      begin
        result:=fen_true;
        if n.nodetype<>loadn then
          exit;
        ctx:=premap(arg);
        idx:=visible_index_of(ctx^.oldpd,tloadnode(n).symtableentry);
        if idx<0 then
          exit;
        newpv:=nth_visible_para(ctx^.newpd,idx);
        if not assigned(newpv) then
          exit;
        tloadnode(n).symtableentry:=newpv;
        tloadnode(n).symtable:=ctx^.newpd.parast;
      end;


    { build the forwarding actual-parameter list: header params -> body call }
    function forward_paras(pd : tprocdef) : tcallparanode;
      var
        i : longint;
        pv : tparavarsym;
      begin
        result:=nil;
        for i:=0 to pd.paras.count-1 do
          begin
            pv:=tparavarsym(pd.paras[i]);
            if vo_is_hidden_para in pv.varoptions then
              continue;
            result:=ccallparanode.create(cloadnode.create(pv,pd.parast),result);
          end;
      end;


    function partialinline_make_header(pd : tprocdef; out headercode : tnode) : tprocdef;
      var
        headerpd : tprocdef;
        bodysym : tprocsym;
        oldsym : tprocsym;
        origrealname : string;
        st : tsymtable;
        ctx : tremap;
        callnode : tnode;
        guard : tnode;
        block : tblocknode;
        stmt : tstatementnode;
      begin
        result:=nil;
        headercode:=nil;
        if (pending_pd<>pd) or not assigned(pending_guard) then
          exit;
        guard:=pending_guard;
        pending_pd:=nil;
        pending_guard:=nil;

        oldsym:=tprocsym(pd.procsym);
        st:=pd.owner;
        origrealname:=oldsym.realname;

        { 1. give the (unchanged) body routine its own private procsym so the
             original name is free for the header }
        bodysym:=cprocsym.create('$partialbody$'+origrealname);
        st.insertsym(bodysym);
        oldsym.ProcdefList.Remove(pd);
        pd.procsym:=bodysym;
        bodysym.ProcdefList.Add(pd);

        { 2. create the header procdef under the *original* procsym (now empty),
             with a fresh cloned signature and a fresh private mangled name }
        headerpd:=create_procdef_alias(pd,origrealname,
          pd.mangledname+'$partialhdr',st,nil,tsk_none,nil);
        headerpd.forwarddef:=false;
        headerpd.interfacedef:=false;
        { the header is the whole point: make it inlinable, never the body }
        include(headerpd.procoptions,po_inline);
        exclude(headerpd.procoptions,po_noinline);

        { 3. remap the copied guard from the body's parameters to the header's,
             then re-create its exit nodes so they are re-analysed cleanly in the
             header's context (the copies carry a resultdef/binding from the body) }
        ctx.oldpd:=pd;
        ctx.newpd:=headerpd;
        foreachnodestatic(pm_postprocess,guard,@remap_load,@ctx);
        foreachnodestatic(pm_postprocess,guard,@rebuild_exit,nil);

        { 4. build:  <guard> ;  Body(params)  (procedures only in this landing) }
        callnode:=ccallnode.create(forward_paras(headerpd),bodysym,st,nil,[],nil);

        stmt:=cstatementnode.create(callnode,nil);
        stmt:=cstatementnode.create(guard,stmt);
        block:=cblocknode.create(stmt);

        headercode:=block;
        result:=headerpd;
      end;

end.
