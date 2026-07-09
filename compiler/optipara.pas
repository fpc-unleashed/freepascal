{
    Interprocedural register allocation (-OoIPARA)

    Ports the idea of gcc's -fipa-ra to FPC, operating intra-unit at code-gen
    time.  When the code generator finishes a routine, that routine's body has
    already been register-allocated, so its instruction stream uses real
    physical registers and the register allocator knows exactly which physical
    registers the body touches (rg[bank].used_in_proc -- the very set FPC uses
    to decide which callee-saved registers to push/pop in the prologue).

    RecordProcClobbers snapshots, per register bank, the intersection of that
    used set with the ABI's volatile (caller-saved) register set and stores it
    on the tprocdef.  That intersection is precisely the set of caller-saved
    registers the routine may clobber.  Crucially it is already transitively
    complete: whenever the routine makes a call, the caller side allocates the
    callee's clobber registers around that call (the full ABI mask for an
    un-analysed callee, or -- with -OoIPARA -- the callee's own reduced set),
    and those allocations flow into used_in_proc.  So a routine that calls an
    unknown/full-ABI target ends up with the full volatile mask and yields no
    reduction at its own call sites (safe); a routine that only calls small
    proven leaves inherits just their small clobber sets.

    Because a wrong (too-small) clobber set silently corrupts caller state,
    anything whose machine-level clobbers cannot be modelled precisely is marked
    "full" (ipara_full) so callers fall back to the complete ABI caller-saved
    mask: assembler routines, routines containing an inline-asm block, routines
    that use exceptions, and external routines.

    The consumer side lives in ncgcal (tcgcallnode.pass_generate_code): for a
    direct call to an already-recorded, non-full routine it narrows the set of
    volatile registers allocated around the call to the callee's clobber set.

    This module is free software; see the FPC copying conditions.
}
unit optipara;

{$i fpcdefs.inc}

interface

    uses
      globtype,
      cgutils,
      symdef;

    { Record, on PD, the volatile-register clobber summary of the routine whose
      code has just been generated. FLAGS is the finishing routine's
      current_procinfo.flags. Must be called while the code generator's register
      allocators are still alive (i.e. before done_register_allocators). }
    procedure RecordProcClobbers(pd : tprocdef; const flags : tprocinfoflags);

    { Retrieve the recorded clobber summary for a (direct) call target PD.
      Returns true and fills the per-bank volatile clobber sets only when PD has
      a proven, reduced summary; returns false (=> caller must use the full ABI
      mask) for un-analysed / forward / full-fallback routines. }
    function GetProcClobbers(pd : tprocdef;
                             out clobber_int,clobber_mm,
                                 clobber_fpu,clobber_addr : tcpuregisterset) : boolean;

implementation

    uses
      symconst,
      cgbase,
      cgobj,
      paramgr;


    procedure RecordProcClobbers(pd : tprocdef; const flags : tprocinfoflags);
      begin
        if not assigned(pd) then
          exit;
        pd.ipara_analyzed:=true;
        pd.ipara_full:=false;
        pd.ipara_clobber_int:=[];
        pd.ipara_clobber_mm:=[];
        pd.ipara_clobber_fpu:=[];
        pd.ipara_clobber_addr:=[];

        { fall back to the full ABI mask for anything whose real machine-level
          clobber set we cannot capture precisely from used_in_proc:
            - pure assembler routines skip register allocation entirely
            - a routine with an inline-asm block may clobber registers the
              register allocator does not fully track
            - a routine that uses exceptions is irrelevant to record as a leaf
              anyway (it would never be a candidate we recurse into for gain),
              and keeping it conservative costs nothing
            - external routines have no body here }
        if (po_assembler in pd.procoptions) or
           (po_external in pd.procoptions) or
           (pi_has_assembler_block in flags) or
           (pi_uses_exceptions in flags) then
          begin
            pd.ipara_full:=true;
            exit;
          end;

        { the register allocators must still be alive }
        if not assigned(cg) or not assigned(cg.rg[R_INTREGISTER]) then
          begin
            pd.ipara_full:=true;
            exit;
          end;

        pd.ipara_clobber_int:=
          cg.rg[R_INTREGISTER].used_in_proc *
          paramanager.get_volatile_registers_int(pd.proccalloption);

        if assigned(cg.rg[R_ADDRESSREGISTER]) then
          pd.ipara_clobber_addr:=
            cg.rg[R_ADDRESSREGISTER].used_in_proc *
            paramanager.get_volatile_registers_address(pd.proccalloption);

        if assigned(cg.rg[R_FPUREGISTER]) then
          pd.ipara_clobber_fpu:=
            cg.rg[R_FPUREGISTER].used_in_proc *
            paramanager.get_volatile_registers_fpu(pd.proccalloption);

        if assigned(cg.rg[R_MMREGISTER]) then
          pd.ipara_clobber_mm:=
            cg.rg[R_MMREGISTER].used_in_proc *
            paramanager.get_volatile_registers_mm(pd.proccalloption);
      end;


    function GetProcClobbers(pd : tprocdef;
                             out clobber_int,clobber_mm,
                                 clobber_fpu,clobber_addr : tcpuregisterset) : boolean;
      begin
        clobber_int:=[];
        clobber_mm:=[];
        clobber_fpu:=[];
        clobber_addr:=[];
        result:=false;
        if not assigned(pd) or not pd.ipara_analyzed or pd.ipara_full then
          exit;
        clobber_int:=pd.ipara_clobber_int;
        clobber_mm:=pd.ipara_clobber_mm;
        clobber_fpu:=pd.ipara_clobber_fpu;
        clobber_addr:=pd.ipara_clobber_addr;
        result:=true;
      end;

end.
