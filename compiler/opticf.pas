{
    Identical Code Folding (-OoICF)

    Ports the idea of gcc's -fipa-icf (gcc/ipa-icf.cc) and the gold linker's
    --icf to FPC, operating intra-unit at the assembler-list level.

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
    (the "representative"); every later duplicate has its instruction body
    replaced by a single `jmp <representative>` thunk.  Crucially this is a
    thunk, never a symbol alias: the duplicate keeps its own distinct symbol and
    therefore its own distinct address, so Pascal's @f<>@g semantics survive
    even when a folded routine's address is taken and compared.  All of the
    duplicate's labels are preserved (they may be referenced by the already
    generated debug/CFI list), so nothing dangles.  FPC's exception model does
    not rely on DWARF .eh_frame unwinding, so replacing a cold duplicate body
    with a tail jump into the (identical) representative is transparent.

    Deliberately conservative -- correctness over coverage:
      - only routines whose body is straight-line instructions, labels, aligns,
        (extra) symbols and comments fold; anything with embedded constants,
        strings, cfi, unhandled operand kinds, etc. is skipped;
      - a routine only folds when it has enough instructions that the 5-byte
        thunk is a guaranteed net shrink;
      - a routine whose address is taken needs no special handling because the
        thunk preserves the address anyway.

    Opt-in via -OoICF; NOT part of the -O4 defaults.

    This module is free software; see the FPC copying conditions.
}
unit opticf;

{$i fpcdefs.inc}

interface

    uses
      aasmdata;

    { Fold byte-identical routines within ALIST (typically
      current_asmdata.asmlists[al_procedures]) into jump thunks.  Returns the
      number of routines folded. }
    function OptimizeICF(alist : TAsmList) : longint;

implementation

    uses
      globtype,cutils,cclasses,
      cpubase,aasmbase,aasmtai,aasmcpu,cgbase,cgutils;

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
      { one candidate routine found in the asmlist }
      ticfroutine = class
        startsym  : tai_symbol;     { the routine's own (mangled) symbol }
        symend    : tai;            { matching ait_symbol_end }
        canon     : ansistring;     { canonical body signature }
        instrs    : longint;        { number of instructions in body }
        foldable  : boolean;
      end;

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

    { Build the canonical body signature of the routine bracketed by
      STARTSYM..SYMEND.  Sets foldable/instrs on the result record. }
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
                  own_register(map,tai_symbol(hp).sym.name);
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
              rt.foldable:=true;
            end;
        finally
          map.Free;
        end;
      end;

    { Replace the body of duplicate DUP with a single jmp to the representative
      REP, keeping all of DUP's labels/symbols. }
    procedure fold_routine(alist : TAsmList; dup, rep : ticfroutine);
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
                        current_asmdata.RefAsmSymbol(rep.startsym.sym.name,AT_FUNCTION));
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

    function OptimizeICF(alist : TAsmList) : longint;
      var
        routines : TFPObjectList;
        byhash   : TFPHashList;
        hp       : tai;
        rt       : ticfroutine;
        rep      : ticfroutine;
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
                 (tai_symbol(hp).sym.bind in [AB_LOCAL,AB_GLOBAL]) then
                begin
                  rt:=ticfroutine.Create;
                  rt.startsym:=tai_symbol(hp);
                  rt.symend:=nil;
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

          { bucket foldable routines by canonical signature and fold duplicates }
          for i:=0 to routines.Count-1 do
            begin
              rt:=ticfroutine(routines[i]);
              if not rt.foldable then
                continue;
              rep:=ticfroutine(byhash.Find(rt.canon));
              if rep=nil then
                byhash.Add(rt.canon,rt)
              else
                begin
                  fold_routine(alist,rt,rep);
                  inc(OptimizeICF);
                end;
            end;
        finally
          byhash.Free;
          routines.Free;
        end;
      end;

{$else x86}

    function OptimizeICF(alist : TAsmList) : longint;
      begin
        { ICF is currently implemented for x86 only }
        OptimizeICF:=0;
      end;

{$endif x86}

end.
