{
    Final value replacement + dead loop elimination (-OoFINALVALUE)

    Ports the idea of gcc's -ftree-scev-cprop (scalar-evolution final-value
    replacement) plus the whole-loop deletion its control-dependent DCE then
    performs, to FPC.  Operates on one routine's node tree, on the still-
    structured tfor-nodes, before -OoFORLOOP / ConvertForLoops lower them.

    Transform (conservative first landing):

      A counted for-loop

          for i := a to b do inc(s,c);        // or  s := s + c
          use(s);

      whose whole body is a SINGLE accumulator update of a plain local
      integer  s  by a loop-invariant amount  c  is replaced by the closed
      form of s's exit value and the loop is deleted:

          if a <= b then s := s + (b-a+1)*c;
          use(s);

      For a downto loop the guard/trip count use  to <= from .  A loop with
      an EMPTY body (and an unused counter) is deleted outright.  Because the
      loop no longer updates s, every post-loop use of s reads the closed
      form directly -- i.e. final-value replacement without touching the use
      sites.

    Soundness (correctness over coverage):

      * only integer inductions; the loop counter is a plain local integer
        of at most 32 bits, so the symbolic trip count  b-a+1  is exact in
        64-bit arithmetic (max ~2^32);
      * the accumulator s is a plain local integer, distinct from the
        counter, updated exactly once per iteration by s := s +/- c;
      * c and the bounds a,b are loop-invariant, side-effect free integer
        expressions referencing neither i nor s (so no double-evaluation or
        aliasing hazard -- the bounds are read once at the loop position just
        as the for-loop would, before s is stored);
      * the counter is not referenced anywhere outside the loop (its exit
        value is dead), so deleting the loop changes no observable use;
      * ZERO-TRIP loops (b<a ascending, a<b downto) are handled by the
        a<=b / to<=from guard: s is then left unchanged, exactly like the
        loop running zero times;
      * two's-complement wraparound is preserved: without overflow checking
        s0 + iters*c (mod 2^n) equals the repeated addition, so the closed
        form is bit-identical.  Under -Co (overflow) or -Cr (range) the loop
        would trap on the overflowing iteration while the closed form would
        not, so the whole pass is DISABLED under either;
      * a body that is anything other than the single accumulator update
        (calls, stores, control flow, breaks/continues/exits, nested loops)
        never matches, so such loops are never deleted.

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


    { count the effective (non-nothing) leaf statements of a loop body and,
      when there is exactly one, return it in SINGLE }
    procedure count_effective(n : tnode; var cnt : integer; var single : tnode);
      begin
        if not assigned(n) then
          exit;
        case n.nodetype of
          blockn:
            count_effective(tblocknode(n).left,cnt,single);
          statementn:
            begin
              count_effective(tstatementnode(n).left,cnt,single);
              count_effective(tstatementnode(n).right,cnt,single);
            end;
          nothingn:
            ; { ignore }
          else
            begin
              inc(cnt);
              single:=n;
            end;
        end;
      end;


    { ---- loop-invariance / side-effect check ------------------------------ }

    type
      pinvctx = ^tinvctx;
      tinvctx = record
        isym,ssym : tsym;
        ok : boolean;
      end;

    function inv_check(var n : tnode; arg : pointer) : foreachnoderesult;
      var
        ctx : pinvctx;
      begin
        result:=fen_false;
        ctx:=pinvctx(arg);
        case n.nodetype of
          ordconstn,addn,subn,muln,unaryminusn,typeconvn:
            ; { pure integer arithmetic over invariants: fine }
          loadn:
            if (tloadnode(n).symtableentry=ctx^.isym) or
               (tloadnode(n).symtableentry=ctx^.ssym) then
              ctx^.ok:=false;
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
      references neither the counter ISYM nor the accumulator SSYM ? }
    function is_simple_invariant(expr : tnode; isym,ssym : tsym) : boolean;
      var
        ctx : tinvctx;
      begin
        ctx.isym:=isym;
        ctx.ssym:=ssym;
        ctx.ok:=true;
        foreachnodestatic(expr,@inv_check,@ctx);
        result:=ctx.ok;
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


    { A plain local integer variable usable as counter/accumulator: a local
      var, integer, at most MAXSIZE bytes (0 = no limit), and NOT address-taken,
      captured by a nested scope, or volatile -- so the whole-routine scans see
      every one of its uses and no alias can change it behind our back. }
    function simple_local_int(n : tnode; maxsize : longint) : boolean;
      var
        sym : tsym;
      begin
        result:=false;
        n:=strip_conv(n);
        if not (assigned(n) and (n.nodetype=loadn)) then
          exit;
        sym:=tloadnode(n).symtableentry;
        if not (sym is tlocalvarsym) then
          exit;
        if tabstractnormalvarsym(sym).addr_taken or
           tabstractnormalvarsym(sym).different_scope or
           (vo_volatile in tabstractnormalvarsym(sym).varoptions) then
          exit;
        if not is_integer(n.resultdef) then
          exit;
        if (maxsize<>0) and (n.resultdef.size>maxsize) then
          exit;
        result:=true;
      end;


    function try_transform(var n : tnode; ctx : pfvctx) : boolean;
      var
        fn : tfornode;
        backward : boolean;
        isym,ssym : tsym;
        sdef : tdef;
        cnt : integer;
        stmt,lhs,r,o1,o2,cexpr : tnode;
        negative : boolean;
        loexpr,hiexpr : tnode;
        count,product,newval,guard,assign : tnode;
        single : tnode;
      begin
        result:=false;
        fn:=tfornode(n);

        { for-step loops (step<>1) are lowered separately; only step 1 here }
        if assigned(fn.loopstep) then
          exit;

        { overflow / range checking would make the closed form observably
          differ from the trapping loop -> disable }
        if ([cs_check_overflow,cs_check_range]*current_settings.localswitches)<>[] then
          exit;
        if ([cs_check_overflow,cs_check_range]*fn.localswitches)<>[] then
          exit;

        backward:=lnf_backward in fn.loopflags;

        { counter: plain local integer, at most 32 bits (so b-a+1 is exact
          in 64-bit) }
        if not simple_local_int(fn.left,4) then
          exit;
        isym:=tloadnode(strip_conv(fn.left)).symtableentry;

        { bounds must be invariant, side-effect free, and independent of the
          counter (they are evaluated once, before s is stored) }
        if not is_simple_invariant(fn.right,isym,nil) then
          exit;
        if not is_simple_invariant(fn.t1,isym,nil) then
          exit;

        { counter's exit value must be dead: no reference outside the loop.
          loads_of(whole tree) = loads_of(loop subtree) means every use of
          the counter is inside this loop. }
        if loads_of(ctx^.code,isym)<>loads_of(fn,isym) then
          exit;

        { classify the body }
        cnt:=0;
        single:=nil;
        count_effective(fn.t2,cnt,single);

        if cnt=0 then
          begin
            { empty body: a pure dead counted loop -> delete outright }
            n:=cnothingnode.create;
            fn.free;
            do_firstpass(n);
            exit(true);
          end;

        if cnt<>1 then
          exit;
        stmt:=single;

        negative:=false;
        cexpr:=nil;
        lhs:=nil;

        case stmt.nodetype of
          assignn:
            begin
              { source form  s := s + c / s := c + s / s := s - c
                (also inc/dec after lowering to an assignment) }
              lhs:=strip_conv(tassignmentnode(stmt).left);
              if not simple_local_int(lhs,0) then
                exit;
              ssym:=tloadnode(lhs).symtableentry;
              if ssym=isym then
                exit;
              r:=strip_conv(tassignmentnode(stmt).right);
              case r.nodetype of
                addn:
                  begin
                    o1:=taddnode(r).left;
                    o2:=taddnode(r).right;
                    if is_load_of(o1,ssym) then
                      cexpr:=o2
                    else if is_load_of(o2,ssym) then
                      cexpr:=o1
                    else
                      exit;
                  end;
                subn:
                  begin
                    o1:=taddnode(r).left;
                    o2:=taddnode(r).right;
                    if is_load_of(o1,ssym) then
                      begin
                        cexpr:=o2;
                        negative:=true;
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
              negative:=tinlinenode(stmt).inlinenumber=in_dec_x;
              o1:=tinlinenode(stmt).left;  { first callparanode }
              if not (assigned(o1) and (o1.nodetype=callparan)) then
                exit;
              lhs:=strip_conv(tcallparanode(o1).left);   { the counter/accumulator var }
              if not simple_local_int(lhs,0) then
                exit;
              ssym:=tloadnode(lhs).symtableentry;
              if ssym=isym then
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
                  cexpr:=tcallparanode(o2).left;
                end
              else
                cexpr:=nil;   { step of 1 }
            end;
          else
            exit;
        end;

        sdef:=lhs.resultdef;

        { the increment c must be loop-invariant and independent of i and s
          (nil means an implicit step of 1) }
        if assigned(cexpr) and not is_simple_invariant(cexpr,isym,ssym) then
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

        { count = hi - lo + 1  (in 64-bit, exact for <=32-bit counters) }
        count:=caddnode.create_internal(addn,
                 caddnode.create_internal(subn,
                   ctypeconvnode.create_internal(hiexpr.getcopy,s64inttype),
                   ctypeconvnode.create_internal(loexpr.getcopy,s64inttype)),
                 cordconstnode.create(1,s64inttype,false));

        { product = count * c  (mod 2^64: low bits match the repeated adds).
          For an implicit step of 1 (cexpr=nil) the product is just count. }
        if assigned(cexpr) then
          product:=caddnode.create_internal(muln,count,
                     ctypeconvnode.create_internal(cexpr.getcopy,s64inttype))
        else
          product:=count;

        { newval = s +/- (product truncated to s's type) }
        if negative then
          newval:=caddnode.create_internal(subn,
                    cloadnode.create(ssym,ssym.owner),
                    ctypeconvnode.create_internal(product,sdef))
        else
          newval:=caddnode.create_internal(addn,
                    cloadnode.create(ssym,ssym.owner),
                    ctypeconvnode.create_internal(product,sdef));

        assign:=cassignmentnode.create(cloadnode.create(ssym,ssym.owner),newval);

        { guard: only assign when the loop would have run (lo <= hi) so a
          zero-trip loop leaves s unchanged }
        guard:=cifnode.create(
                 caddnode.create_internal(lten,loexpr.getcopy,hiexpr.getcopy),
                 assign,nil);

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
