{
    Identical Code Folding (-OoICF)

    Ports the idea of gcc's -fipa-icf (gcc/ipa-icf.cc) and the gold linker's
    --icf to FPC, operating at the assembler-list level.

    After every routine of a module has been generated, its final instruction
    list lives back-to-back inside current_asmdata.asmlists[al_procedures],
    each routine bracketed by an ait_symbol (the mangled routine symbol) and its
    matching ait_symbol_end.  This pass walks that list, and for every foldable
    routine builds a *canonical* signature of its body:

      - the opcode, operand size and condition of each instruction;
      - every operand encoding (registers, immediates, memory references with
        their base/index/scale/segment/offset/refaddr);
      - references to symbols abstracted to the referenced symbol *name*, EXCEPT
        that references to the routine's own symbol(s) and its own local labels
        are rewritten to positional tokens (assigned in definition order).

    Two routines with equal canonical signatures emit byte-identical machine
    code (their bodies differ only in the routine's own symbol name and local
    label names, neither of which affects the emitted bytes -- only relocation
    *targets*, which the symbolisation has already proven structurally equal).
    Comparing the full canonical strings for equality IS the byte-verify step;
    the hashing is only used to bucket candidates cheaply.

    For each group of equal routines the first one encountered is kept intact
    (the "representative"); every later duplicate is collapsed into it, in one
    of two ways:

      1. jmp thunk (default): the duplicate's instruction body is replaced by a
         single `jmp <representative>`.  The duplicate keeps its own distinct
         symbol and therefore its own distinct address, so Pascal's @f<>@g
         semantics survive even when a folded routine's address is taken and
         compared.

      2. symbol alias (-OoICF, when provably safe): a *zero byte* fold -- the
         duplicate's entry symbol is emitted as an additional label at the
         representative's address (the same "two labels, one location" mechanism
         the code generator already uses for e.g. main/PASCALMAIN) and the
         duplicate's own body is dropped entirely.  This is only done when the
         duplicate's address can never be observed as a value, so that making
         @dup = @rep true is unobservable:
           - the duplicate symbol is unit-local (not global/exported/public):
             no other unit can take its address;
           - its address is never loaded as a value in this unit
             (tprocdef.icf_addrtaken, set by tloadnode.create_procvar);
           - it is a plain routine, not a virtual/external method (whose address
             leaks implicitly through a VMT / RTTI / method pointer).
         Anything failing these falls back to the address-preserving thunk.

    Cross-unit folding (shared PPU optimizer-summary mechanism):
      Each globally-visible routine that survives intra-unit folding stores a
      128-bit digest of its canonical body on its tprocdef (icf_hash), which
      symdef.write_optimizer_summary persists as the optsum_icf ppu tag, guarded
      by the target/ABI/-Cf instruction-set signature.  When a later unit is
      compiled, every used unit's summary is loaded and its survivors registered
      here (ICFRegisterExternalSurvivor, keyed by digest -> global mangled name).
      A routine of the unit being compiled whose canonical digest matches such a
      survivor -- and which found no intra-unit representative -- folds into a
      jmp thunk to that external global symbol.  Cross-unit duplicated generic
      specializations are the primary win.

      Collision stance: cross-unit we only carry the 128-bit digest, not the
      body, so (unlike the intra-unit pass, which byte-verifies via full-string
      compare) a cross-unit fold trusts digest equality alone.  The digest mixes
      the *entire* canonical instruction stream with two independent 64-bit
      avalanche hashes; for any realistic number of routines the birthday-bound
      collision probability (~n^2/2^128) is astronomically small, and a spurious
      match could only fold two routines whose full canonical streams collide
      under both mixers AND that were compiled for the identical target/ABI
      signature.  Cross-unit folds are therefore always thunks (never aliases):
      the survivor lives in another object, and a thunk keeps every duplicate's
      own address intact regardless of who takes it.

    Deliberately conservative -- correctness over coverage:
      - only routines whose body is straight-line instructions, labels, aligns,
        (extra) symbols and comments fold; anything with embedded constants,
        strings, cfi, unhandled operand kinds, etc. is skipped;
      - a routine only folds when it has enough instructions that the 5-byte
        thunk is a guaranteed net shrink.

    Opt-in via -OoICF; NOT part of the -O4 defaults.

    This module is free software; see the FPC copying conditions.
}
unit opticf;

{$i fpcdefs.inc}

interface

    uses
      globtype,cclasses,
      aasmdata;

    { Fold byte-identical routines within ALIST (typically
      current_asmdata.asmlists[al_procedures]) into jump thunks / symbol
      aliases.  Returns the number of routines folded. }
    function OptimizeICF(alist : TAsmList) : longint;

    { Register (name -> tprocdef) so the pass can consult a routine's tprocdef
      (address-taken / visibility / hash storage).  Called once per generated
      routine while a module is being compiled, only when -OoICF is active. PD
      is a tprocdef (typed as TObject to keep this interface free of symdef). }
    procedure ICFRegisterRoutine(const mangledname : TSymStr; pd : TObject);

    { Register a fold survivor loaded from a used unit's ppu (optsum_icf tag):
      its 128-bit canonical digest -> its global mangled name.  Accumulates for
      the whole compilation (never reset per module). }
    procedure ICFRegisterExternalSurvivor(h0,h1 : qword; const mangledname : TSymStr);

implementation

    uses
      cutils,
      cpubase,aasmbase,aasmtai,aasmcpu,cgbase,cgutils,
      symconst,symbase,symtype,symdef;

{$ifdef x86}

    const
      { minimum number of body instructions for a fold to be a net size win
        (a jmp rel32 thunk is 5 bytes) }
      min_fold_instrs = 4;

      { body tai that carry no machine-code bytes of their own (debug markers,
        register/temp bookkeeping, comments); ignored when hashing and dropped
        or kept when folding.  Anything NOT in this set and not one of the
        structural types (instruction/label/symbol/align/symbol_end) is treated
        as data-bearing and makes the routine non-foldable. }
      icf_ignore_tai = [ait_comment,ait_regalloc,ait_tempalloc,ait_marker,
                        ait_varloc,ait_function_name,ait_force_line];

    type
      { holder for a cross-unit survivor's global name (owns a stable copy of
        the ansistring beyond the used unit's ppu load buffers) }
      ticfextern = class
        name : TSymStr;
      end;

      { one candidate routine found in the asmlist }
      ticfroutine = class
        startsym  : tai_symbol;     { the routine's own (mangled) symbol }
        symend    : tai;            { matching ait_symbol_end }
        canon     : ansistring;     { canonical body signature }
        h0,h1     : qword;          { 128-bit digest of canon }
        pd        : tprocdef;       { owning procdef (nil if not registered) }
        instrs    : longint;        { number of instructions in body }
        foldable  : boolean;
        folded    : boolean;        { collapsed into a thunk/alias -> not a survivor }
        has_local_dup : boolean;    { another routine folded into this one }
        single_entry : boolean;     { exactly one entry symbol (no extra aliasnames) }
      end;

    { module-scoped mangledname -> tprocdef registry, filled during codegen and
      cleared once this module's pass has run }
    var
      icf_routine_map : TFPHashList;
      { compilation-scoped digest("h0:h1") -> ticfextern (survivor global name) }
      icf_extern_map : TFPHashList;
      { owns the ticfextern holders for the whole compilation }
      icf_extern_own : TFPObjectList;

    { positional name map: routine-own symbol / local label names -> token index }
    procedure own_register(map : TFPHashList; const n : TSymStr);
      begin
        if map.Find(n)=nil then
          { store index+1 so that nil (not found) stays distinguishable }
          map.Add(n,Pointer(PtrInt(map.Count+1)));
      end;

    function own_token(map : TFPHashList; const n : TSymStr) : ansistring;
      var
        p : Pointer;
      begin
        p:=map.Find(n);
        if p<>nil then
          own_token:='@'+tostr(PtrInt(p))
        else
          own_token:='x:'+n;
      end;

    function canon_sym(map : TFPHashList; s : tasmsymbol) : ansistring;
      begin
        if s=nil then
          canon_sym:='-'
        else
          canon_sym:=own_token(map,s.name);
      end;

    function canon_ref(map : TFPHashList; const r : treference) : ansistring;
      begin
        canon_ref:='o'+tostr(r.offset)+
                   'b'+tostr(longint(r.base))+
                   'i'+tostr(longint(r.index))+
                   's'+tostr(r.scalefactor)+
                   'a'+tostr(ord(r.refaddr))+
                   'g'+tostr(longint(r.segment))+
                   'y'+canon_sym(map,r.symbol)+
                   'z'+canon_sym(map,r.relsymbol);
      end;

    { Serialise one operand; sets ok=false on an operand kind we cannot prove
      byte-equal. }
    function canon_oper(map : TFPHashList; const o : toper; var ok : boolean) : ansistring;
      begin
        case o.typ of
          top_none:
            canon_oper:='N';
          top_reg:
            canon_oper:='R'+tostr(longint(o.reg));
          top_const:
            canon_oper:='C'+tostr(o.val);
          top_ref:
            canon_oper:='M'+canon_ref(map,o.ref^);
          top_bool:
            canon_oper:='B'+tostr(ord(o.b));
          else
            begin
              ok:=false;
              canon_oper:='?';
            end;
        end;
      end;

    { 128-bit digest of S: two independent 64-bit multiply/xor/rotate avalanche
      hashes over the full canonical byte stream (different seeds + multipliers).
      Non-cryptographic but well-mixed; see the collision stance in the unit
      header. }
    procedure hash128(const s : ansistring; out o0,o1 : qword);
      const
        seed0 = qword($cbf29ce484222325);  { FNV-1a offset basis }
        mul0  = qword($100000001b3);       { FNV-1a prime }
        seed1 = qword($9e3779b97f4a7c15);  { golden-ratio odd constant }
        mul1  = qword($ff51afd7ed558ccd);  { Murmur3 fmix constant }
      var
        a,b : qword;
        i : longint;
        c : qword;
      begin
        a:=seed0;
        b:=seed1;
        for i:=1 to length(s) do
          begin
            c:=qword(ord(s[i]));
            { stream 0: FNV-1a }
            a:=(a xor c)*mul0;
            { stream 1: xor-in, rotate, multiply }
            b:=b xor (c+qword(i));
            b:=((b shl 27) or (b shr 37))*mul1;
          end;
        { final avalanche so short/similar inputs diffuse fully }
        a:=a xor (a shr 33); a:=a*mul1; a:=a xor (a shr 29);
        b:=b xor (b shr 31); b:=b*mul0; b:=b xor (b shr 27);
        o0:=a;
        o1:=b;
      end;

    { short, collision-free string form of a 128-bit digest, safe as a
      shortstring hash-list key }
    function digestkey(h0,h1 : qword) : string;
      begin
        digestkey:=tostr(h0)+':'+tostr(h1);
      end;

    { Build the canonical body signature of the routine bracketed by
      STARTSYM..SYMEND.  Sets foldable/instrs/canon/h0/h1 on the result record. }
    procedure build_canon(rt : ticfroutine);
      var
        map : TFPHashList;
        hp  : tai;
        ai  : taicpu;
        i   : longint;
        ok  : boolean;
        s   : ansistring;
      begin
        rt.foldable:=false;
        rt.instrs:=0;
        rt.single_entry:=true;
        map:=TFPHashList.Create;
        try
          { pass 1: register the routine's own definitions (symbols + labels) in
            definition order, so forward references resolve to a stable token }
          own_register(map,rt.startsym.sym.name);
          hp:=tai(rt.startsym.next);
          while (hp<>nil) and (hp<>rt.symend) do
            begin
              case hp.typ of
                ait_symbol:
                  begin
                    own_register(map,tai_symbol(hp).sym.name);
                    { an extra entry symbol in the body (a second aliasname): the
                      routine has more than one entry, so it must not be collapsed
                      to a symbol alias (we would only move the primary symbol and
                      strand the others) }
                    rt.single_entry:=false;
                  end;
                ait_label:
                  own_register(map,tai_label(hp).labsym.name);
                ait_instruction,ait_align,ait_symbol_end:
                  ;
                else
                  if not (hp.typ in icf_ignore_tai) then
                    { data-bearing / unhandled tai in body: give up on this one }
                    exit;
              end;
              hp:=tai(hp.next);
            end;
          if hp<>rt.symend then
            exit;

          { pass 2: serialise the byte-affecting content }
          ok:=true;
          s:='';
          hp:=tai(rt.startsym.next);
          while (hp<>nil) and (hp<>rt.symend) do
            begin
              case hp.typ of
                ait_instruction:
                  begin
                    ai:=taicpu(hp);
                    s:=s+'I'+tostr(ord(ai.opcode))+'/'+tostr(ord(ai.opsize))+
                       '/'+tostr(ord(ai.condition))+
                       '/'+tostr(longint(ai.segprefix))+'(';
                    for i:=0 to ai.ops-1 do
                      s:=s+canon_oper(map,ai.oper[i]^,ok)+',';
                    s:=s+')';
                    inc(rt.instrs);
                  end;
                ait_label:
                  s:=s+'L'+own_token(map,tai_label(hp).labsym.name);
                ait_symbol:
                  s:=s+'S'+own_token(map,tai_symbol(hp).sym.name)+
                     tostr(ord(tai_symbol(hp).is_global));
                ait_align:
                  s:=s+'A'+tostr(tai_align_abstract(hp).aligntype)+
                     '/'+tostr(tai_align_abstract(hp).fillsize)+
                     '/'+tostr(tai_align_abstract(hp).fillop)+
                     '/'+tostr(ord(tai_align_abstract(hp).use_op));
                ait_symbol_end:
                  { non-emitting: ignore for the signature };
                else
                  if not (hp.typ in icf_ignore_tai) then
                    exit;
              end;
              hp:=tai(hp.next);
            end;

          if ok and (rt.instrs>=min_fold_instrs) then
            begin
              rt.canon:=s;
              hash128(s,rt.h0,rt.h1);
              rt.foldable:=true;
            end;
        finally
          map.Free;
        end;
      end;

    { Replace the body of DUP with a single jmp to the symbol named TARGETNAME
      (the intra-unit representative, or a cross-unit external survivor), keeping
      all of DUP's labels/symbols. }
    procedure fold_to_thunk(alist : TAsmList; dup : ticfroutine; const targetname : TSymStr);
      var
        hp,nexthp : tai;
        jmpi      : taicpu;
        jmpdone   : boolean;
      begin
        jmpdone:=false;
        hp:=tai(dup.startsym.next);
        while (hp<>nil) and (hp<>dup.symend) do
          begin
            nexthp:=tai(hp.next);
            case hp.typ of
              ait_instruction:
                begin
                  if not jmpdone then
                    begin
                      jmpi:=taicpu.op_sym(A_JMP,S_NO,
                        current_asmdata.RefAsmSymbol(targetname,AT_FUNCTION));
                      alist.InsertBefore(jmpi,hp);
                      jmpdone:=true;
                    end;
                  alist.Remove(hp);
                  hp.Free;
                end;
              ait_comment,ait_regalloc,ait_tempalloc,ait_varloc:
                begin
                  { drop the now-meaningless allocation/comment/var-tracking noise }
                  alist.Remove(hp);
                  hp.Free;
                end;
              else
                { keep labels, (extra) symbols, aligns, markers, symbol_end };
            end;
            hp:=nexthp;
          end;
      end;

    { Zero-byte fold: emit DUP's entry symbol as an additional label at REP's
      start (two labels, one address) and drop DUP's own body entirely.  DUP's
      local labels are kept in place (empty) because the already generated
      debug/CFI list references them; only DUP's own entry symbol moves, and its
      ait_symbol_end (whose ".size dup,.-dup" would now straddle two sections) is
      dropped. }
    procedure fold_to_alias(alist : TAsmList; dup, rep : ticfroutine);
      var
        hp,nexthp : tai;
        aliassym  : tai_symbol;
      begin
        { define DUP's symbol at REP's location, right after REP's entry symbol }
        if dup.startsym.is_global then
          aliassym:=tai_symbol.create_global(dup.startsym.sym,0)
        else
          aliassym:=tai_symbol.create(dup.startsym.sym,0);
        alist.InsertAfter(aliassym,rep.startsym);

        { remove DUP's original entry symbol, its instructions and its
          symbol_end; keep its local labels / extra symbols / aligns in place }
        hp:=dup.startsym;
        while hp<>nil do
          begin
            nexthp:=tai(hp.next);
            if hp=dup.startsym then
              begin
                alist.Remove(hp);
                hp.Free;
              end
            else if hp=dup.symend then
              begin
                alist.Remove(hp);
                hp.Free;
                break;
              end
            else
              case hp.typ of
                ait_instruction,
                ait_comment,ait_regalloc,ait_tempalloc,ait_varloc:
                  begin
                    alist.Remove(hp);
                    hp.Free;
                  end;
                else
                  { keep labels / extra symbols / aligns };
              end;
            hp:=nexthp;
          end;
      end;

    { True when DUP may be collapsed to a zero-byte symbol alias of REP without
      ever making @dup=@rep observable.

      Note we deliberately do NOT gate on the ELF symbol's global bind: under the
      default section-per-symbol smartlinking EVERY routine symbol is emitted
      global so the linker can resolve cross-section references, yet an
      implementation-section / nested routine is still un-nameable from any other
      unit's source, so no source anywhere can form @dup.  We gate on that
      *source-level* visibility instead. }
    function alias_safe(dup : ticfroutine) : boolean;
      var
        st : tsymtabletype;
      begin
        alias_safe:=false;
        { a multi-entry routine (extra aliasnames) would strand its other entry
          symbols if we moved only the primary one to the survivor }
        if not dup.single_entry then
          exit;
        if not assigned(dup.pd) or not assigned(dup.pd.procsym) or
           not assigned(dup.pd.procsym.owner) then
          exit;
        { address loaded as a value somewhere in this unit }
        if dup.pd.icf_addrtaken then
          exit;
        { a routine nameable from another unit (interface / exported / public /
          external) can have its address taken where we cannot see it }
        st:=dup.pd.procsym.owner.symtabletype;
        if not (st in [staticsymtable,localsymtable]) then
          exit;
        if (po_exports in dup.pd.procoptions) or
           (po_external in dup.pd.procoptions) or
           (po_virtualmethod in dup.pd.procoptions) or
           (po_public in dup.pd.procoptions) then
          exit;
        { any method: its address can leak implicitly through a VMT / RTTI /
          method-pointer construction we do not track }
        if assigned(dup.pd.struct) then
          exit;
        alias_safe:=true;
      end;

    procedure ICFRegisterRoutine(const mangledname : TSymStr; pd : TObject);
      begin
        if not assigned(icf_routine_map) then
          icf_routine_map:=TFPHashList.Create;
        { last writer wins; a name maps to at most one procdef per module }
        if icf_routine_map.Find(mangledname)=nil then
          icf_routine_map.Add(mangledname,pd);
      end;

    procedure ICFRegisterExternalSurvivor(h0,h1 : qword; const mangledname : TSymStr);
      var
        key : TSymStr;
        e : ticfextern;
      begin
        if not assigned(icf_extern_map) then
          begin
            icf_extern_map:=TFPHashList.Create;
            icf_extern_own:=TFPObjectList.Create(true);
          end;
        key:=digestkey(h0,h1);
        { first survivor for a digest wins; keep a stable ansistring copy so it
          survives the used unit's ppu load buffers being released }
        if icf_extern_map.Find(key)=nil then
          begin
            e:=ticfextern.Create;
            e.name:=mangledname;
            icf_extern_own.Add(e);
            icf_extern_map.Add(key,e);
          end;
      end;

    function extern_survivor(h0,h1 : qword) : TSymStr;
      var
        e : ticfextern;
      begin
        extern_survivor:='';
        if not assigned(icf_extern_map) then
          exit;
        e:=ticfextern(icf_extern_map.Find(digestkey(h0,h1)));
        if assigned(e) then
          extern_survivor:=e.name;
      end;

    function OptimizeICF(alist : TAsmList) : longint;
      var
        routines : TFPObjectList;
        byhash   : TFPHashList;
        hp       : tai;
        rt       : ticfroutine;
        rep      : ticfroutine;
        extname  : TSymStr;
        i        : longint;
      begin
        OptimizeICF:=0;
        if alist=nil then
          exit;

        routines:=TFPObjectList.Create(true);
        byhash:=TFPHashList.Create;
        try
          { collect candidate routines: an ait_symbol of a function, up to its
            matching ait_symbol_end }
          hp:=tai(alist.First);
          while hp<>nil do
            begin
              if (hp.typ=ait_symbol) and
                 (tai_symbol(hp).sym<>nil) and
                 (tai_symbol(hp).sym.typ=AT_FUNCTION) and
                 (tai_symbol(hp).sym.bind in [AB_LOCAL,AB_GLOBAL,AB_PRIVATE_EXTERN]) then
                begin
                  rt:=ticfroutine.Create;
                  rt.startsym:=tai_symbol(hp);
                  rt.symend:=nil;
                  rt.pd:=nil;
                  rt.folded:=false;
                  rt.has_local_dup:=false;
                  { find the matching symbol_end for this exact symbol }
                  hp:=tai(hp.next);
                  while hp<>nil do
                    begin
                      if (hp.typ=ait_symbol_end) and
                         (tai_symbol_end(hp).sym=rt.startsym.sym) then
                        begin
                          rt.symend:=hp;
                          break;
                        end;
                      { a new function symbol before our end: give up on this one }
                      if (hp.typ=ait_symbol) and
                         (tai_symbol(hp).sym<>nil) and
                         (tai_symbol(hp).sym.typ=AT_FUNCTION) then
                        break;
                      hp:=tai(hp.next);
                    end;
                  if rt.symend<>nil then
                    begin
                      if assigned(icf_routine_map) then
                        rt.pd:=tprocdef(icf_routine_map.Find(rt.startsym.sym.name));
                      build_canon(rt);
                      routines.Add(rt);
                      { continue scanning after this routine's end }
                      hp:=tai(rt.symend);
                    end
                  else
                    begin
                      rt.Free;
                      { hp already advanced to a boundary or nil }
                      continue;
                    end;
                end;
              if hp<>nil then
                hp:=tai(hp.next);
            end;

          { Bucket foldable routines and fold intra-unit duplicates.  We key the
            bucket on the short 128-bit digest string (mangled names / the canon
            key are shortstrings here, so a >255-char canon would truncate) and
            still verify byte-equality by comparing the FULL canonical strings
            before folding -- the digest only groups candidates cheaply. }
          for i:=0 to routines.Count-1 do
            begin
              rt:=ticfroutine(routines[i]);
              if not rt.foldable then
                continue;
              rep:=ticfroutine(byhash.Find(digestkey(rt.h0,rt.h1)));
              { a digest hit with a differing full canon is a (near-impossible)
                collision: refuse to fold, keep the first representative }
              if (rep<>nil) and (rep.canon<>rt.canon) then
                continue;
              if rep=nil then
                byhash.Add(digestkey(rt.h0,rt.h1),rt)
              else
                begin
                  { intra-unit duplicate: alias when provably safe, else thunk }
                  if alias_safe(rt) then
                    fold_to_alias(alist,rt,rep)
                  else
                    fold_to_thunk(alist,rt,rep.startsym.sym.name);
                  rt.folded:=true;
                  rep.has_local_dup:=true;
                  inc(OptimizeICF);
                end;
            end;

          { Cross-unit folding: a still-unfolded routine whose digest matches a
            survivor from a used unit folds into a jmp thunk to that external
            global symbol.  Always a thunk (never an alias): the survivor lives
            in another object, and a thunk keeps every duplicate's own address
            intact regardless of who takes it.  A routine that already anchors a
            local fold group is kept as a real local body. }
          if assigned(icf_extern_map) then
            for i:=0 to routines.Count-1 do
              begin
                rt:=ticfroutine(routines[i]);
                if (not rt.foldable) or rt.folded or rt.has_local_dup then
                  continue;
                extname:=extern_survivor(rt.h0,rt.h1);
                if (extname<>'') and (extname<>rt.startsym.sym.name) then
                  begin
                    fold_to_thunk(alist,rt,extname);
                    rt.folded:=true;
                    inc(OptimizeICF);
                  end;
              end;

          { Publish surviving globally-visible routines (still a full local body)
            as cross-unit fold survivors for later units, guarded downstream by
            the target/ABI signature in write_optimizer_summary. }
          for i:=0 to routines.Count-1 do
            begin
              rt:=ticfroutine(routines[i]);
              if rt.foldable and not rt.folded and
                 assigned(rt.pd) and rt.pd.needsglobalasmsym then
                begin
                  rt.pd.icf_hash[0]:=rt.h0;
                  rt.pd.icf_hash[1]:=rt.h1;
                  rt.pd.icf_hash_valid:=true;
                end;
            end;
        finally
          byhash.Free;
          routines.Free;
          { the per-module name->procdef registry is consumed; clear it so the
            next module starts fresh (the cross-unit survivor map persists) }
          if assigned(icf_routine_map) then
            icf_routine_map.Clear;
        end;
      end;

{$else x86}

    procedure ICFRegisterRoutine(const mangledname : TSymStr; pd : TObject);
      begin
      end;

    procedure ICFRegisterExternalSurvivor(h0,h1 : qword; const mangledname : TSymStr);
      begin
      end;

    function OptimizeICF(alist : TAsmList) : longint;
      begin
        { ICF is currently implemented for x86 only }
        OptimizeICF:=0;
      end;

{$endif x86}

end.
