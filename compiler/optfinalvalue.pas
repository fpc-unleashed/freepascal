{
    Final value replacement + dead loop elimination (-OoFINALVALUE)

    Ports the idea of gcc's -ftree-scev-cprop (scalar-evolution final-value
    replacement) plus the whole-loop deletion its control-dependent DCE then
    performs, to FPC.  Operates on one routine's node tree, on the still-
    structured tfor-nodes, before -OoFORLOOP / ConvertForLoops lower them.

    Transform (conservative first landing + follow-ups):

      A counted for-loop

          for i := a to b do inc(s,c);        // or  s := s + c
          use(s);

      whose whole body is one or more INDEPENDENT accumulator updates, each
      of a distinct plain local integer OR pointer  s  by a loop-invariant
      amount  c , is replaced by the closed form of every accumulator's exit
      value and the loop is deleted:

          for i := a to b do begin s := s + cs;  p := p + cp end;   // body
      ->  if a <= b then begin
            s := s + (b-a+1)*cs;
            p := p + (b-a+1)*cp;                 // pointer: advances by
          end;                                   // (b-a+1)*cp elements
          use(s); use(p);

      For a downto loop the guard/trip count use  to <= from .  A loop with
      an EMPTY body (and an unused counter) is deleted outright.  Because the
      loop no longer updates the accumulators, every post-loop use reads the
      closed form directly -- i.e. final-value replacement without touching
      the use sites.

    Follow-ups landed on top of the integer single-statement first cut:

      * POINTER-STRIDE accumulators (p := p + stride / inc(p,stride)): the
        closed form  p + (iters*stride)  is built as a pointer+integer
        addnode, so the compiler applies the same element-size scaling the
        loop body did; iters*stride (mod 2^64) scaled by the element size
        equals the repeated pointer advance bit-for-bit;
      * MULTI-STATEMENT bodies: a body that is several statements, each an
        independent accumulator update of a DISTINCT variable, matches -- one
        closed form per accumulator under the shared trip-count guard.  The
        accumulators are distinct and no increment references another, so
        they evolve independently and statement order is irrelevant;
      * 64-BIT COUNTERS: the counter may be any integer up to 64 bits.  The
        trip count  b-a+1  is computed in 64-bit two's-complement, giving the
        true iteration count reduced mod 2^64; every accumulator product is
        truncated to the accumulator's own width w<=64, and (count*c) mod 2^w
        is bit-identical to the repeated addition (pointer strides use the
        product as an element count, likewise correct mod 2^64), so a 64-bit
        counter is exactly as sound as a 32-bit one;
      * RANGE CHECKING (-Cr, without -Co): still enabled, restricted to native
        full-range integer accumulators (int64/qword) whose  s:=s+c  performs
        no narrowing and so is never range-checked, matching the nf_internal
        closed form.  -Co (overflow checking) stays fully disabled (see below);
      * STATIC / GLOBAL accumulators: a unit-level (static) variable may be an
        accumulator (never the counter).  The loop body has no calls and the
        routine no exception paths, so nothing observes the intermediate
        states cross-routine within this thread, and the closed form stores
        the identical final value.

    Soundness (correctness over coverage):

      * the loop counter is a plain LOCAL integer of at most 64 bits (a static
        counter is rejected: the whole-routine deadness scan cannot see its
        cross-unit uses).  The trip count is exact mod 2^64, which is all the
        truncated products need;
      * each accumulator s is a plain local (or, for statics, global) integer
        or pointer, distinct from the counter AND from every other accumulator,
        updated exactly once per iteration by s := s +/- c;
      * every c and the bounds a,b are loop-invariant, side-effect free
        integer expressions referencing neither i nor ANY accumulator (so no
        double-evaluation or aliasing hazard -- the bounds are read once at
        the loop position just as the for-loop would, before any s is stored);
      * the counter is not referenced anywhere outside the loop (its exit
        value is dead), so deleting the loop changes no observable use;
      * ZERO-TRIP loops (b<a ascending, a<b downto) are handled by the
        a<=b / to<=from guard: the accumulators are then left unchanged,
        exactly like the loop running zero times;
      * two's-complement wraparound is preserved: without overflow checking
        s0 + iters*c (mod 2^n) equals the repeated addition, so the closed
        form is bit-identical.  Under -Cr the pass runs only for native
        full-range integer accumulators, which -Cr never range-checks; under
        -Co (overflow) it is DISABLED, because a native accumulator would trap
        on the overflowing iteration and reproducing that per-iteration trap
        from a single closed-form step is not robustly sound;
      * a body containing anything other than accumulator updates (calls,
        stores, control flow, breaks/continues/exits, nested loops), or two
        updates of the SAME accumulator, never matches, so such loops are
        never deleted.

    Opt-in via -OoFINALVALUE; NOT part of the -O4 defaults.  A wrong final
    value or a wrongly-deleted loop is a miscompile, hence the conservatism.

    This module is free software; see the FPC copying conditions.
}
unit optfinalvalue;

{$i fpcdefs.inc}

interface

    uses
      node;

    { rewrite eligible counted loops in the routine tree CODE to their
      closed-form final value + delete the (now empty) loop }
    procedure OptimizeFinalValue(var code : tnode);

implementation

    uses
      globtype,globals,constexp,
      symconst,symtype,symsym,symdef,
      defutil,
      nutils,nbas,nflw,nld,nadd,ncon,ncnv,ninl,ncal,
      compinnr,
      pass_1;


    { ---- small helpers ---------------------------------------------------- }

    { strip surrounding type conversions to reach the payload node }
    function strip_conv(n : tnode) : tnode;
      begin
        while assigned(n) and (n.nodetype=typeconvn) do
          n:=ttypeconvnode(n).left;
        result:=n;
      end;


    { is n (ignoring type conversions) a load of symbol sym ? }
    function is_load_of(n : tnode; sym : tsym) : boolean;
      begin
        n:=strip_conv(n);
        result:=assigned(n) and (n.nodetype=loadn) and
                (tloadnode(n).symtableentry=sym);
      end;


    const
      { at most this many independent accumulator updates in one loop body }
      MAXACC = 64;

    type
      tnodearr = array[0..MAXACC-1] of tnode;
      tsymarr  = array[0..MAXACC] of tsym;    { isym + up to MAXACC accs }

    { collect the effective (non-nothing) leaf statements of a loop body into
      ARR.  CNT is the running count; it is set to -1 if the body has more than
      MAXACC effective statements (caller then bails out). }
    procedure collect_stmts(n : tnode; var arr : tnodearr; var cnt : integer);
      begin
        if (cnt<0) or not assigned(n) then
          exit;
        case n.nodetype of
          blockn:
            collect_stmts(tblocknode(n).left,arr,cnt);
          statementn:
            begin
              collect_stmts(tstatementnode(n).left,arr,cnt);
              collect_stmts(tstatementnode(n).right,arr,cnt);
            end;
          nothingn:
            ; { ignore }
          else
            begin
              if cnt>=MAXACC then
                begin cnt:=-1; exit; end;
              arr[cnt]:=n;
              inc(cnt);
            end;
        end;
      end;


    { ---- loop-invariance / side-effect check ------------------------------ }

    type
      pinvctx = ^tinvctx;
      tinvctx = record
        forbidden : ^tsymarr;   { syms the expression must not reference }
        nforbidden : integer;
        ok : boolean;
      end;

    function inv_check(var n : tnode; arg : pointer) : foreachnoderesult;
      var
        ctx : pinvctx;
        sym : tsym;
        k : integer;
      begin
        result:=fen_false;
        ctx:=pinvctx(arg);
        case n.nodetype of
          ordconstn,addn,subn,muln,unaryminusn,typeconvn:
            ; { pure integer arithmetic over invariants: fine }
          loadn:
            begin
              sym:=tloadnode(n).symtableentry;
              for k:=0 to ctx^.nforbidden-1 do
                if ctx^.forbidden^[k]=sym then
                  begin
                    ctx^.ok:=false;
                    break;
                  end;
            end;
          else
            { anything else (calls, inline intrinsics, derefs, indexing,
              address-of, assignments, ...) is not provably invariant /
              side-effect free }
            ctx^.ok:=false;
        end;
        if not ctx^.ok then
          result:=fen_norecurse_false;
      end;


    { is EXPR a loop-invariant, side-effect-free integer expression that
      references none of the NFORBIDDEN syms in FORBIDDEN (counter + accs) ? }
    function is_invariant(expr : tnode; var forbidden : tsymarr; nforbidden : integer) : boolean;
      var
        ctx : tinvctx;
      begin
        ctx.forbidden:=@forbidden;
        ctx.nforbidden:=nforbidden;
        ctx.ok:=true;
        foreachnodestatic(expr,@inv_check,@ctx);
        result:=ctx.ok;
      end;

    { convenience: invariance against a single symbol (the counter) }
    function is_invariant1(expr : tnode; sym : tsym) : boolean;
      var
        one : tsymarr;
      begin
        one[0]:=sym;
        result:=is_invariant(expr,one,1);
      end;


    { ---- reference counting ----------------------------------------------- }

    type
      pcountctx = ^tcountctx;
      tcountctx = record
        sym : tsym;
        count : integer;
      end;

    function count_load(var n : tnode; arg : pointer) : foreachnoderesult;
      begin
        result:=fen_false;
        if (n.nodetype=loadn) and
           (tloadnode(n).symtableentry=pcountctx(arg)^.sym) then
          inc(pcountctx(arg)^.count);
      end;

    function loads_of(n : tnode; sym : tsym) : integer;
      var
        ctx : tcountctx;
      begin
        ctx.sym:=sym;
        ctx.count:=0;
        foreachnodestatic(n,@count_load,@ctx);
        result:=ctx.count;
      end;


    { ---- the transform ---------------------------------------------------- }

    type
      pfvctx = ^tfvctx;
      tfvctx = record
        code : tnode;       { whole routine tree, for out-of-loop scans }
        changed : boolean;
      end;


    { true for a native-width, full-range integer type (int64/qword on a
      64-bit target): an  s:=s+c  in such a type performs no narrowing, so -Cr
      inserts no range check.  Identity against the canonical type defs excludes
      subranges (which get their own def), and is_nativeint excludes oversized
      ints on 32-bit targets. }
    function is_native_full_range_int(def : tdef) : boolean;
      begin
        result:=assigned(def) and is_nativeint(def) and
                ((def=s64inttype) or (def=u64inttype));
      end;


    { A plain variable usable as counter/accumulator: NOT address-taken,
      captured by a nested scope, or volatile -- so the whole-routine scans see
      every one of its uses and no alias can change it behind our back.  It must
      be an integer of at most MAXSIZE bytes (0 = no limit), or -- when
      ALLOW_POINTER -- a pointer (ISPTR is set accordingly).

      Normally the variable must be a plain LOCAL.  When ALLOW_STATIC (used for
      accumulators only, never the loop counter) a unit-level / global (static)
      variable is also accepted: the loop body has no calls and the enclosing
      routine no exception paths (both enforced elsewhere), so no cross-routine
      code observes the global's intermediate states within this thread, and the
      closed form writes the identical final value -- the same reason FPC may
      already keep such an accumulator in a register across the loop.  Threadvars
      and external symbols, whose observers we cannot bound, stay rejected. }
    function simple_local_var(n : tnode; maxsize : longint; allow_pointer, allow_static : boolean; out isptr : boolean) : boolean;
      var
        sym : tsym;
      begin
        result:=false;
        isptr:=false;
        n:=strip_conv(n);
        if not (assigned(n) and (n.nodetype=loadn)) then
          exit;
        sym:=tloadnode(n).symtableentry;
        if sym is tlocalvarsym then
          begin
            { plain local: different_scope means it is captured by a nested
              routine and could be modified behind our back -> reject }
            if tabstractnormalvarsym(sym).different_scope then
              exit;
          end
        else if allow_static and (sym is tstaticvarsym) then
          begin
            { a static/global is legitimately reached from a scope other than
              its declaration, so different_scope is normally set and benign
              here; reject only threadvars / externals whose observers we
              cannot bound }
            if ([vo_is_thread_var,vo_is_external]*tabstractvarsym(sym).varoptions)<>[] then
              exit;
          end
        else
          exit;
        if tabstractnormalvarsym(sym).addr_taken or
           (vo_volatile in tabstractnormalvarsym(sym).varoptions) then
          exit;
        if is_integer(n.resultdef) then
          { plain integer: ok }
        else if allow_pointer and is_pointer(n.resultdef) then
          isptr:=true
        else
          exit;
        if (maxsize<>0) and (n.resultdef.size>maxsize) then
          exit;
        result:=true;
      end;

    { integer-only shorthand (the loop counter must be a plain local integer --
      never a static/global, whose cross-unit uses the whole-routine deadness
      scan cannot see) }
    function simple_local_int(n : tnode; maxsize : longint) : boolean;
      var
        dummy : boolean;
      begin
        result:=simple_local_var(n,maxsize,false,false,dummy);
      end;


    { one matched accumulator update  s := s +/- c  ( c=nil means step 1 ) }
    type
      taccrec = record
        sym : tsym;      { the accumulated variable }
        cexpr : tnode;   { increment amount (nil => 1); NOT copied, owned by loop }
        negative : boolean;
        isptr : boolean; { s is a pointer -> pointer-stride final value }
        sdef : tdef;     { s's type (integer truncation target) }
      end;


    { match STMT against a single accumulator update of a plain local integer or
      pointer distinct from the counter ISYM; on success fill ACC and return
      true.  Does NOT check cexpr invariance (needs the full accumulator set). }
    function match_accumulator(stmt : tnode; isym : tsym; out acc : taccrec) : boolean;
      var
        lhs,r,o1,o2 : tnode;
      begin
        result:=false;
        acc.sym:=nil; acc.cexpr:=nil; acc.negative:=false; acc.isptr:=false; acc.sdef:=nil;

        case stmt.nodetype of
          assignn:
            begin
              { source form  s := s + c / s := c + s / s := s - c
                (also inc/dec after lowering to an assignment) }
              lhs:=strip_conv(tassignmentnode(stmt).left);
              if not simple_local_var(lhs,0,true,true,acc.isptr) then
                exit;
              { the pointer  p := p + stride  form is rejected here: by the
                time this pass runs the add has been typechecked, so stride is
                already multiplied by the element size, and rebuilding a
                pointer+integer closed form would scale it a second time.  The
                still-unlowered  inc(p,stride)  form below carries the raw
                (unscaled) element stride and IS supported. }
              if acc.isptr then
                exit;
              acc.sym:=tloadnode(lhs).symtableentry;
              if acc.sym=isym then
                exit;
              r:=strip_conv(tassignmentnode(stmt).right);
              case r.nodetype of
                addn:
                  begin
                    o1:=taddnode(r).left;
                    o2:=taddnode(r).right;
                    if is_load_of(o1,acc.sym) then
                      acc.cexpr:=o2
                    else if is_load_of(o2,acc.sym) then
                      acc.cexpr:=o1
                    else
                      exit;
                  end;
                subn:
                  begin
                    o1:=taddnode(r).left;
                    o2:=taddnode(r).right;
                    if is_load_of(o1,acc.sym) then
                      begin
                        acc.cexpr:=o2;
                        acc.negative:=true;
                      end
                    else
                      exit;
                  end;
                else
                  exit;
              end;
            end;
          inlinen:
            begin
              { still-unlowered  inc(s[,c]) / dec(s[,c])  -- a for-loop body's
                inc node is not lowered to an assignment until after this pass }
              if not (tinlinenode(stmt).inlinenumber in [in_inc_x,in_dec_x]) then
                exit;
              acc.negative:=tinlinenode(stmt).inlinenumber=in_dec_x;
              o1:=tinlinenode(stmt).left;  { first callparanode }
              if not (assigned(o1) and (o1.nodetype=callparan)) then
                exit;
              lhs:=strip_conv(tcallparanode(o1).left);   { the accumulator var }
              if not simple_local_var(lhs,0,true,true,acc.isptr) then
                exit;
              acc.sym:=tloadnode(lhs).symtableentry;
              if acc.sym=isym then
                exit;
              { increment amount: the optional second parameter (default 1) }
              o2:=tcallparanode(o1).right;
              if assigned(o2) then
                begin
                  if o2.nodetype<>callparan then
                    exit;
                  { reject inc(s,a,b,...) with extra params }
                  if assigned(tcallparanode(o2).right) then
                    exit;
                  acc.cexpr:=tcallparanode(o2).left;
                end
              else
                acc.cexpr:=nil;   { step of 1 }
            end;
          else
            exit;
        end;

        acc.sdef:=lhs.resultdef;
        result:=true;
      end;


    function try_transform(var n : tnode; ctx : pfvctx) : boolean;
      var
        fn : tfornode;
        backward : boolean;
        co,cr : boolean;
        isym : tsym;
        cnt,k,j : integer;
        stmts : tnodearr;
        accs : array[0..MAXACC-1] of taccrec;
        forbidden : tsymarr;      { isym + every accumulator sym }
        nforbidden : integer;
        loexpr,hiexpr : tnode;
        count,product,newval : tnode;
        guard,blk : tnode;
        laststmt : tstatementnode;
      begin
        result:=false;
        fn:=tfornode(n);

        { for-step loops (step<>1) are lowered separately; only step 1 here }
        if assigned(fn.loopstep) then
          exit;

        { Overflow (-Co) / range (-Cr) checking.  The closed form is built
          entirely from nf_internal nodes, so it never traps; the original loop
          may.  Two regimes:

            * -Co (overflow checking): a native-width accumulator loop traps on
              the overflowing iteration while the wrap-around closed form does
              not, and a sub-native accumulator's trap-freedom relies on FPC
              promoting the add to native width -- a fragile implementation
              detail.  Matching the per-iteration trap semantics in a single
              closed-form step is not robustly sound, so DISABLE outright.

            * -Cr without -Co: sound *iff* neither the loop body nor the closed
              form can raise a range error.  s:=s+c range-faults under -Cr only
              on the narrowing store back into a sub-native / subrange
              accumulator; for a native-width, full-range integer (int64/qword)
              the add stays native and -Cr inserts no check -- matching the
              nf_internal closed form bit-for-bit.  So under -Cr we proceed but
              require the counter and every accumulator to be native full-range
              integers (enforced below); pointers and sub-native/subrange
              accumulators are rejected. }
        co:=(cs_check_overflow in current_settings.localswitches) or
            (cs_check_overflow in fn.localswitches);
        cr:=(cs_check_range in current_settings.localswitches) or
            (cs_check_range in fn.localswitches);
        if co then
          exit;

        backward:=lnf_backward in fn.loopflags;

        { counter: plain local integer, at most 64 bits.  The symbolic trip
          count  b-a+1  is computed in 64-bit two's-complement, so it is the
          true iteration count reduced mod 2^64; every accumulator product is
          then truncated to the accumulator's own width, and (count*c) mod 2^w
          is bit-identical to the repeated addition for any w<=64 -- so a
          64-bit counter is as exact as a 32-bit one for the truncated result
          and the pointer-stride element count. }
        if not simple_local_int(fn.left,8) then
          exit;
        isym:=tloadnode(strip_conv(fn.left)).symtableentry;
        { the counter type is unconstrained under -Cr: the loop terminates at
          the bound so its own increment never range-faults, and the guard /
          trip-count copy the original bound expressions verbatim (including any
          narrowing conversion the for-loop applied), so any bound range fault
          happens identically in the closed form. }

        { bounds must be invariant, side-effect free, and independent of the
          counter (they are evaluated once, before any s is stored) }
        if not is_invariant1(fn.right,isym) then
          exit;
        if not is_invariant1(fn.t1,isym) then
          exit;

        { counter's exit value must be dead: no reference outside the loop.
          loads_of(whole tree) = loads_of(loop subtree) means every use of
          the counter is inside this loop. }
        if loads_of(ctx^.code,isym)<>loads_of(fn,isym) then
          exit;

        { classify the body: collect the effective leaf statements }
        cnt:=0;
        collect_stmts(fn.t2,stmts,cnt);

        if cnt=0 then
          begin
            { empty body: a pure dead counted loop -> delete outright.  This
              discards the bound expressions, which is sound only when their
              evaluation cannot trap.  Without -Cr the bounds are pure invariant
              integer arithmetic that only wraps; under -Cr a bound may carry a
              narrowing conversion that range-faults at loop entry, so keep the
              loop (the accumulator path is not reached for an empty body, so its
              fault-preserving guard cannot stand in here). }
            if cr then
              exit;
            n:=cnothingnode.create;
            fn.free;
            do_firstpass(n);
            exit(true);
          end;

        if cnt<0 then     { more than MAXACC statements: give up }
          exit;

        { every statement must be an independent accumulator update }
        forbidden[0]:=isym;
        nforbidden:=1;
        for k:=0 to cnt-1 do
          begin
            if not match_accumulator(stmts[k],isym,accs[k]) then
              exit;
            { under -Cr only native full-range integer accumulators are sound
              (see the regime note above): a pointer, sub-native or subrange
              accumulator would be range-checked on its narrowing store while
              the nf_internal closed form would not }
            if cr and (accs[k].isptr or not is_native_full_range_int(accs[k].sdef)) then
              exit;
            { each accumulator must be distinct from all earlier ones (two
              updates of the same variable would double-count) }
            for j:=0 to k-1 do
              if accs[j].sym=accs[k].sym then
                exit;
            forbidden[nforbidden]:=accs[k].sym;
            inc(nforbidden);
          end;

        { every increment c must be loop-invariant and reference neither the
          counter nor ANY accumulator (nil means an implicit step of 1) }
        for k:=0 to cnt-1 do
          if assigned(accs[k].cexpr) and
             not is_invariant(accs[k].cexpr,forbidden,nforbidden) then
            exit;

        { --- all checks passed: build the closed form --------------------- }

        { ascending: lo=from(right), hi=to(t1); downto: lo=to(t1), hi=from(right) }
        if backward then
          begin
            loexpr:=fn.t1;
            hiexpr:=fn.right;
          end
        else
          begin
            loexpr:=fn.right;
            hiexpr:=fn.t1;
          end;

        { one closed-form assignment per accumulator, all under one guard }
        blk:=internalstatements(laststmt);
        for k:=0 to cnt-1 do
          begin
            { count = hi - lo + 1  (in 64-bit, exact for <=32-bit counters) }
            count:=caddnode.create_internal(addn,
                     caddnode.create_internal(subn,
                       ctypeconvnode.create_internal(hiexpr.getcopy,s64inttype),
                       ctypeconvnode.create_internal(loexpr.getcopy,s64inttype)),
                     cordconstnode.create(1,s64inttype,false));

            { product = count * c  (mod 2^64: low bits match the repeated adds).
              For an implicit step of 1 (cexpr=nil) the product is just count. }
            if assigned(accs[k].cexpr) then
              product:=caddnode.create_internal(muln,count,
                         ctypeconvnode.create_internal(accs[k].cexpr.getcopy,s64inttype))
            else
              product:=count;

            if accs[k].isptr then
              begin
                { pointer stride: newval = p +/- product, built as a
                  pointer+integer add so the compiler scales the element count
                  (product) by the pointed-to element size exactly as the loop
                  body's  inc(p,stride) / p:=p+stride  did }
                if accs[k].negative then
                  newval:=caddnode.create_internal(subn,
                            cloadnode.create(accs[k].sym,accs[k].sym.owner),product)
                else
                  newval:=caddnode.create_internal(addn,
                            cloadnode.create(accs[k].sym,accs[k].sym.owner),product);
              end
            else
              begin
                { integer: newval = s +/- (product truncated to s's type) }
                if accs[k].negative then
                  newval:=caddnode.create_internal(subn,
                            cloadnode.create(accs[k].sym,accs[k].sym.owner),
                            ctypeconvnode.create_internal(product,accs[k].sdef))
                else
                  newval:=caddnode.create_internal(addn,
                            cloadnode.create(accs[k].sym,accs[k].sym.owner),
                            ctypeconvnode.create_internal(product,accs[k].sdef));
              end;

            addstatement(laststmt,
              cassignmentnode.create(cloadnode.create(accs[k].sym,accs[k].sym.owner),newval));
          end;

        { guard: only assign when the loop would have run (lo <= hi) so a
          zero-trip loop leaves the accumulators unchanged }
        guard:=cifnode.create(
                 caddnode.create_internal(lten,loexpr.getcopy,hiexpr.getcopy),
                 blk,nil);

        n:=guard;
        fn.free;
        do_firstpass(n);
        result:=true;
      end;


    function process_node(var n : tnode; arg : pointer) : foreachnoderesult;
      var
        ctx : pfvctx;
      begin
        result:=fen_false;
        if n.nodetype=forn then
          begin
            ctx:=pfvctx(arg);
            if try_transform(n,ctx) then
              begin
                ctx^.changed:=true;
                { n has been replaced (and the old loop freed); do not recurse
                  into the freed subtree }
                result:=fen_norecurse_true;
              end;
          end;
      end;


    procedure OptimizeFinalValue(var code : tnode);
      var
        ctx : tfvctx;
      begin
        if not assigned(code) then
          exit;
        ctx.code:=code;
        ctx.changed:=false;
        foreachnodestatic(code,@process_node,@ctx);
      end;

end.
