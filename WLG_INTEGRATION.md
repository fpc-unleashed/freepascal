# Integration Guide: Witness-Based Lightweight Generics (WLG)

WLG transitions Free Pascal's generics from a pure compile-time monomorphization (code-duplication) model into a hybrid model using **Shape-Classes**, **Veneer VMTs**, **Mangled Name Redirection**, and **COMDAT Linker Deduplication**.

This allows compiling generic methods and standalone functions once per CPU Shape-Class, reducing executable sizes and I-cache pressure in large-scale applications while fully maintaining Pascal's strict static type safety (`is`/`as` checks).

## What WLG Does

When you write:
```pascal
type
  TUserMapper     = specialize TJSONMapper<TUser>;
  TOrderMapper    = specialize TJSONMapper<TOrder>;
  TProductMapper  = specialize TJSONMapper<TProduct>;
  // ... 16 more specializations
```

**Without WLG (Legacy):** FPC emits 19 duplicate copies of every method body.

**With WLG:** FPC groups types by their ABI layout (Shape-Classes) and emits only 3 method bodies:
- `Shape_POD_4` (Integer-based records) → 1 shared body
- `Shape_POD_8` (Int64-based records) → 1 shared body
- `Shape_Managed` (string-containing records) → 1 shared body

**Result: 84% code reduction** (19 → 3 bodies) for the same functionality.

## Modified Files

The patch modifies approximately 30 files, categorized as follows:

### Front-End & Parser
- **`pdecl.pas`** - WLG routing in specialization parsing
- **`pgentype.pas`** - Shape-class assignment, shared code registry
- **`pgenutil.pas`** - WLG transformations, witness table emission

### Symbol Tables & Metadata
- **`symconst.pas`** - Shape-class enum, WLG definition flags
- **`symdef.pas`** - Extended `tprocdef` with WLG fields, mangled name redirection
- **`symsym.pas`** - Witness symbol handling
- **`defutil.pas`** - `classify_shape()` function
- **`procdefutil.pas`** - Procedure definition utilities

### Configuration
- **`globtype.pas`** - `m_lightweight_generics` modeswitch

### Assembler
- **`aasmbase.pas`** - WLG metadata fields on `TAsmSymbol`
- **`aasmcnst.pas`** - Metadata propagation from parse to object writer
- **`aasmtai.pas`** - Typed const builder for witness tables

### Object Writers
- **`ogbase.pas`** - COMDAT section creation in `symboldefine()`
- **`ogelf.pas`** - ELF-specific COMDAT support
- **`ogcoff.pas`** - COFF-specific COMDAT support
- **`ogmacho.pas`** - Mach-O-specific COMDAT support

### Code Generation
- **`x86_64/cgcpu.pas`** - Dynamic stack frames, Init/Final calls, NR_R12/R13 handling
- **`hlcgobj.pas`** - Local variable address redirection to NR_R12
- **`nobj.pas`** - VMT veneer copying
- **`ncgcal.pas`** - WLG call generation
- **`aggas.pas`** - Assembly output

### RTL Core
- **`rtl/inc/systemh.inc`** - `TWitnessTable` record definition
- **`rtl/inc/generic.inc`** - WLG RTL helper functions

## Safety & Regression Guarding

To guarantee zero-risk integration:

1. **Compile-Time Guard:** All WLG-specific compiler and RTL changes are guarded by `{$IFDEF FPC_HAS_WITNESS_GENERICS}`. If this define is absent, the compiler compiles to its exact, legacy state.

2. **Run-Time Guard:** WLG is completely opt-in. Unless a compiled unit explicitly declares `{$MODESWITCH LIGHTWEIGHTGENERICS}`, the WLG pipeline is bypassed, falling back to standard monomorphization.

3. **Modeswitch Toggle:** `{$MODESWITCH LIGHTWEIGHTGENERICS}` enables WLG; `{$MODESWITCH -LIGHTWEIGHTGENERICS}` disables it. This makes it easy to toggle WLG on/off for testing.

## Implementation Challenges

### Hurdle 1: Object File Writer Mismatch During Parsing (The ICE)
**The Issue:** Attempted to call `create_wlg_comdat_section()` from `finalize_asmlist()` in `aasmcnst.pas`. This caused an Internal Compiler Error because the assembler finalizer runs during parsing, while the binary object writer (`TObjData`) is not instantiated until code generation.

**The Solution:** Implemented a **Metadata Propagation Pattern**. Added metadata fields (`wlg_shapeclass`, `wlg_identity_hash`) to `TAsmSymbol`. During parsing, copy WLG metadata onto `TAsmSymbol`. Later, during binary emission, `TObjData.symboldefine` in `ogbase.pas` intercepts the flagged symbol and diverts its data into a dedicated COMDAT section.

### Hurdle 2: Bypassing `ncgbas.pas` with Symbol-Time Redirection (The R12 Hack)
**The Issue:** Overriding local variable address generation in `ncgbas.pas`/`ResolveRef` would change addressing for every CPU architecture FPC supports, risking regressions on non-x86 targets.

**The Solution:** Bypassed `ncgbas.pas` entirely by pre-populating the symbol's `localloc.reference` record during local variable allocation in `hlcgobj.pas`. Allocated an internal `voidpointertype` stack symbol (`wlg_stack_base`) so FPC's standard stack allocator handles its offset naturally. Pre-populated the dynamic variable's `localloc.reference.base` with `r12`. When `ncgbas.pas` runs, it generates `[r12 + offset]` without needing any WLG-specific code.

### Hurdle 3: The "Generic Template" Code-Gen Skip
**The Issue:** Marking the first specialization's methods with `df_shared_generic` caused the compiler's code-generator to silently skip emitting machine code, causing unresolved external symbol linker errors. FPC's backend treats any definition flagged as generic as an abstract template.

**The Solution:** Audited the compiler's template-skipping checks (`tstoreddef.is_generic` in `symdef.pas`). Explicitly isolated `df_shared_generic` from these checks, ensuring the compiler recognizes it as a concrete, compilable shared body.

### Hurdle 4: Volatile Register Preservation During Init/Final Calls
**The Issue:** When calling `witness^.Init` or `witness^.Final` in the prologue/epilogue loop, parameter registers (e.g., `rsi` on SysV, `rdx` on Win64) are volatile. Multiple dynamic locals would cause register corruption on subsequent iterations.

**The Solution:** In the prologue, copy the witness table pointer from its volatile parameter register into a stable, non-volatile register (`r13`). Add `NR_R13` to `procdef.used_regs` so the compiler automatically generates ABI-compliant `push`/`pop` instructions.

## How to Test

1. Build the compiler with WLG:
   ```bash
   make all OVERRIDEVERSIONCHECK=1 OPT="-dFPC_HAS_WITNESS_GENERICS"
   ```

2. Run the demonstration:
   ```bash
   ./compiler/ppcx64 -Ur -dFPC_HAS_WITNESS_GENERICS \
     -Fu./rtl/units/x86_64-linux \
     -Fu./packages/rtl-objpas/units/x86_64-linux \
     -O3 -XX -CX -Xs wlg_orm_demo.pas
   ./wlg_orm_demo
   ```

3. Run the test suite:
   ```bash
   ./compiler/ppcx64 -dFPC_HAS_WITNESS_GENERICS tests/wlg/twlg_deduplication.pp
   ./compiler/ppcx64 -dFPC_HAS_WITNESS_GENERICS tests/wlg/twlg_integrity.pp
   ./compiler/ppcx64 -dFPC_HAS_WITNESS_GENERICS tests/wlg/twlg_managed.pp
   ./compiler/ppcx64 -dFPC_HAS_WITNESS_GENERICS tests/wlg/twlg_nested.pp
   ```

## Backward Compatibility

- **Zero impact when disabled:** If `FPC_HAS_WITNESS_GENERICS` is not defined, all WLG code is compiled out
- **Opt-in per unit:** Existing code works without modification
- **No PPU format changes for non-WLG code:** Only units using `{$MODESWITCH LIGHTWEIGHTGENERICS}` have extended PPU metadata
- **No ABI changes:** WLG is entirely a compiler-internal optimization