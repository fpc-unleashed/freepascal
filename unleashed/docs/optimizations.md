# Optimizer

Two optimizer switches on top of what stock `-O` levels do: `-OoMEMINLINE` turns small constant-size `FillChar()` / `Move()` calls into direct stores, and `-OoAUTOINLINE` inlines small routines that carry no `inline` directive. Neither needs a mode, a modeswitch or a source change - only an optimization level. A third optimization needs not even that: a call through a procvar whose target is provably one specific routine becomes a direct call at every level - see [Procvar Devirtualization](#procvar-devirtualization).

| Switch | On from | Effect |
|---|---|---|
| `-OoMEMINLINE` | `-O2` | `FillChar()`, `FillByte()`, `FillWord()`, `FillDWord()`, `FillQWord()` and `Move()` with a constant count of at most 64 bytes expand into direct stores instead of an RTL call |
| `-OoAUTOINLINE` | `-O3` | small routines are marked for inlining without an `inline` directive |

`-OoAUTOINLINE` exists in stock Free Pascal too, but is off at every level there: its heuristic priced any control flow as infinitely complex, so a routine holding a single `if` never qualified no matter how the threshold was set. The heuristic here judges the shape of the body instead, which is what makes the switch worth enabling by default.

Both are ordinary optimizer switches, so all the usual ways to address them work:

```
fpc -O2 -OoNOMEMINLINE unit.pas
fpc -O1 -OoMEMINLINE unit.pas
fpc -O3 -Ooautoinline- unit.pas
```

```pascal
{$optimization NOAUTOINLINE}
{$optimization autoinline-}
{$optimization autoinline+}
```

A trailing `+` or `-` on the switch name sets or clears it; the `NO` prefix clears it - the spellings are interchangeable. The directive is read per routine: routines declared while the switch is off compile without the optimization, the ones after turning it back on get it again.

## `-OoMEMINLINE`

A block fill or a block copy of a handful of bytes spends most of its time in the RTL routine's size dispatch, not in the stores. With a constant count the size is known while the tree is still being built, so the call is replaced by the stores it would end up performing.

```pascal
type TFrame = record kind: byte; len, crc: dword; end;   // 12 bytes

var frame: TFrame;

FillChar(frame, sizeof(frame), 0);   // two 8-byte stores, no call
```

### What qualifies

| Requirement | Detail |
|---|---|
| the routine | `FillChar()`, `FillByte()`, `FillWord()`, `FillDWord()`, `FillQWord()` or `Move()` from the `system` unit |
| the count | a constant, at least one element and at most 64 bytes in total: 64 for `FillChar()` / `FillByte()` / `Move()`, 32 words, 16 dwords, 8 qwords. Integer conversions around the constant are seen through |
| the operands | destination (and source, for `Move()`) must have an address. The one case that fails in practice is a constant actual spliced in by an inline expansion, which has no address until the RTL call materializes it |
| the target | the stores are unaligned, so targets that require naturally aligned accesses (ARM, MIPS, SPARC, RISC-V, m68k and the like) keep the call |

A non-constant count, a count over the cap and a zero count all stay a regular call.

### The store pattern

The bytes are covered with naturally sized stores; a size that is not a multiple of the widest store gets a final store overlapping the previous one, which beats a tail of narrower stores.

| Total bytes | Stores |
|---|---|
| 1, 2, 4, 8 | one store of that width |
| 3 | 2 bytes, then 1 byte |
| 5, 6, 7 | 4 bytes at offset 0, then 4 bytes ending at the last byte |
| 9 and up | 8-byte stores from the front, plus a final 8-byte store ending at the last byte when the size is not a multiple of 8 |

So 12 bytes are two 8-byte stores overlapping in the middle, and 64 bytes are eight of them with no overlap.

The address is computed once. A plain variable (global, local or parameter, but not a threadvar) has its address folded into every store; anything else - a field of a dereferenced pointer, an indexed element, a function result - gets one pointer temp, assigned once, exactly like the call would have evaluated its argument once.

### Fill values

A constant fill value is replicated across 64 bits at compile time, so every store gets an immediate. A runtime value is evaluated once into a temp and spread over the 64 bits with a single multiply; narrower stores truncate that temp:

```pascal
FillChar(buf, 16, b);   // t := b * $0101010101010101, then two 8-byte stores of t
```

`FillWord()` / `FillDWord()` use the matching multiplier, `FillQWord()` needs none.

### `Move()` and overlap

The RTL `Move()` handles overlapping source and destination. The expansion has to as well, so it loads every chunk into a temp before the first store, and the two are then equivalent:

```pascal
for var i := 0 to 15 do buf[i] := i;
Move(buf[0], buf[4], 12);   // 00 01 02 03 00 01 02 03 04 05 06 07 08 09 0A 0B
```

## `-OoAUTOINLINE`

At `-O3` a routine that never says `inline` is still inlined when its body is small and simple enough. There is no directive and no source change - a getter, a clamp, a two-line wrapper stops costing a call.

The decision is made once per routine, when its code is generated, and it is reported as a hint at the routine's declaration, so the compiler log tells which routines stopped being real calls:

```
demo.pp(12,1) Hint: Auto inlining: clampToByte(LongInt):System.Byte;
```

Hints are silenced as usual: all of them with `-vh-`, just this one with `-vm6055`.

### What qualifies

The body must fit a node budget and consist only of node kinds worth duplicating:

| Rule | Value |
|---|---|
| body size | at most 40 nodes |
| body size when it contains a call | at most 20 nodes, and at most one call |
| allowed shapes | expressions, assignments, `if`, `case`, `exit`, `raise`, calls, temporaries, type conversions |
| allowed intrinsics | `inc()`, `dec()`, `succ()`, `pred()`, `ord()`, `chr()`, `length()`, `assigned()`, `abs()`, `sqr()`, `sizeof()`, `typeof()`, `lo()`, `hi()`, the `rol` / `ror` family, `include()`, `exclude()`, `aligned()`, `unaligned()`, `volatile()` |

A body holding one call is admitted on purpose: wrappers, overloads that only supply a default argument and guard helpers that raise are exactly the routines worth folding away. The budget is halved for them because each splice duplicates that call's parameter setup as well - without the tighter cap a compiler self-build grows 23% instead of 4%.

### What does not qualify

| Reason | Example |
|---|---|
| a loop | `for`, `while`, `repeat` in the body - unbounded work behind a small node count |
| an exception frame | `try ... except` / `try ... finally` |
| an `asm` block or a `goto` | cannot be priced by a node count |
| an intrinsic that becomes an RTL call | `write()`, `str()`, `new()`, `SetLength()`, ... |
| more than one call | two calls in one body |
| direct recursion | the routine calls itself |
| forwarding an own by-reference parameter | the body passes one of its own parameters on as `var` / `out` / `constref` or to an untyped parameter |
| the body is too big | over the node budget |

On top of that the routine must not already be `inline` or `noinline`, must not declare nested routines, and the usual suspects never enter: constructors, destructors, class constructors and destructors, unit initialization and finalization, the program body, `virtual`, `external`, `exports`, `interrupt`, `iocheck` and `safecall` routines.

### It is not the forced regime

`-OoAUTOINLINE` marks the routine the way an `inline` directive in a stock mode would: the call sites still go through the inliner's own size budget, which shrinks with expansion depth, so a deeply nested chain of auto-inlined calls stops expanding at some point without saying anything. This is the opposite of what an explicit `inline` does in `{$mode unleashed}` - see [Forced Inlining](forced-inline.md), where every direct call expands and a failure is a warning.

`{$inline off}` turns auto-inlining off too: a routine whose body is parsed while the switch is off is never auto-marked, and no call parsed while it is off expands anything - see [Forced Inlining - Turning it off](forced-inline.md#turning-it-off). To address only the automatic marking and leave explicit `inline` routines alone, use `{$optimization autoinline-}` / `-OoNOAUTOINLINE`; to keep one routine out, mark it `noinline`.

## Procvar Devirtualization

A call through a procedure variable that provably holds the address of one specific routine is rewritten into a direct call. No switch, no mode and no optimization level required - the rewrite runs at every level, `-O-` included, and reports a hint at the call site:

```
demo.pp(21,26) Hint: Devirtualized call: doubler(LongInt):System.LongInt;
```

Once the call is direct, the target's inline regime applies like at any other call site: a routine in the [forced regime](forced-inline.md) expands, a small routine is picked up by `-OoAUTOINLINE` at `-O3`, and a `noinline` routine stays a - now direct - call.

### What resolves

Two shapes, chased through at most 4 locations:

- **The address itself.** `@routine` (behind any value-preserving casts) reaching the call: written in place as `TFn(@doubler)(6)`, or spliced into a wrapper's body by the inliner when the wrapper's procvar parameter received `@routine` at the wrapper's own call site.
- **A local with a single store.** A local variable or a compiler temporary whose only store in the whole routine is such an address. The store itself is removed when nothing else reads the location.

```pascal
procedure run;
var
  p: TFn;
begin
  p := @doubler;   // the only store: a routine address
  writeln(p(5));   // direct call; at -O3 folded away entirely
end;
```

The wrapper case is where it adds up. Once `apply` is inlined (forced or auto), its parameter load becomes the address constant, the inner call devirtualizes, `doubler` inlines in turn, and the chain folds to its result:

```pascal
function apply(f: TFn; x: longint): longint;
begin
  result := f(x);
end;

var g := apply(@doubler, 6);   // -O3: g is assigned the constant 12, no calls
```

### What stays indirect

| Case | Why |
|---|---|
| a global or unit-level procvar (program-body `var`s included) | any routine, any thread may store to it |
| a procvar parameter, when the wrapper is not inlined | the value is only known per call site |
| a local with more than one store, its address taken, or `volatile()` | not provably one routine |
| the enclosing routine declares nested routines or contains an `asm` block | they can write locals invisibly |
| a method procvar (`of object`) or a nested procvar | carries a self/frame value along with the address |
| a target with a different calling convention | the rewrite requires a call-identical signature |

Debugging is unaffected: devirtualization never removes the routine or the call, it only changes how the call is made - a breakpoint inside the target still hits. To also keep the target out of inline expansion, mark it `noinline`.

## Demo

```pascal
program optimizations_demo;

{$mode unleashed}

uses
  {$ifdef WINDOWS}windows{$else}baseunix, unix{$endif}, sysutils;

type
  TBuf = array[16] of byte;
  TClampFn = function(v: integer): byte;

// the tick counter has a 15.6 ms resolution on Windows, too coarse for a loop
// that runs in tens of milliseconds
function micros: qword;
{$ifdef WINDOWS}
var freq, cnt: int64;
begin
  QueryPerformanceFrequency(freq);
  QueryPerformanceCounter(cnt);
  result := round(cnt/freq*1000000);
end;
{$else}
var tv: TTimeVal;
begin
  fpgettimeofday(@tv, nil);
  result := qword(tv.tv_sec)*1000000+qword(tv.tv_usec);
end;
{$endif}

// a body of plain expressions and branches, under the node budget: at -O3
// this is picked for automatic inlining without an `inline` directive
function clampToByte(v: integer): byte;
begin
  if v < 0 then result := 0 else if v > 255 then result := 255 else result := byte(v);
end;

function hexOf(const buf: TBuf): string;
begin
  result := '';
  for var i := 0 to high(buf) do result := result+IntToHex(buf[i], 2);
end;

// a local procvar with a single store is devirtualized into a direct call
// at any level (the compiler hints it); at -O3 the target then inlines too
procedure devirtDemo;
var
  clamp: TClampFn;
begin
  clamp := @clampToByte;
  writeln('devirt       ', clamp(300));
end;

var
  buf: TBuf;
  fillValue: byte;
  total: int64 = 0;
  started: qword;

begin
  // 5 bytes: one 4-byte store plus a second one overlapping it
  buf := default(TBuf);
  FillChar(buf, 5, $AB);
  writeln('fill 5       ', hexOf(buf));

  // 7 bytes at a non-zero offset, same overlapping pattern
  buf := default(TBuf);
  FillChar(buf[3], 7, $CD);
  writeln('fill 7 at 3  ', hexOf(buf));

  // a runtime fill value is spread over 64 bits with a single multiply
  fillValue := clampToByte(300);
  FillChar(buf, 16, fillValue);
  writeln('fill runtime ', hexOf(buf));

  // every chunk is loaded before the first store, so an overlapping Move
  // gives what the RTL routine gives
  for var i := 0 to high(buf) do buf[i] := i;
  Move(buf[0], buf[4], 12);
  writeln('move overlap ', hexOf(buf));

  devirtDemo;

  started := micros;
  for var i := 1 to 20000000 do total += clampToByte(i-10000000);
  writeln('sum          ', total, ' in ', micros-started, ' us');

  {$ifdef WINDOWS}readln;{$endif}
end.
```

Output (built with `-O3`; the timing depends on the machine):

```
fill 5       ABABABABAB0000000000000000000000
fill 7 at 3  000000CDCDCDCDCDCDCD000000000000
fill runtime FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
move overlap 00010203000102030405060708090A0B
devirt       255
sum          2549967615 in 16064 us
```

The build log carries the two hints:

```
optimizations_demo.pp(33,1) Hint: Auto inlining: clampToByte(LongInt):System.Byte;
optimizations_demo.pp(50,38) Hint: Devirtualized call: clampToByte(LongInt):System.Byte;
```

None of this changes what the program prints - built with `-O1` it produces the identical lines (and needs about 34000 us for the loop; the devirtualization hint still appears, the auto-inlining one does not). What changes is the code behind them: `-OoNOMEMINLINE` puts three `FillChar()` calls and one `Move()` call back into the assembly, and `-OoNOAUTOINLINE` puts back the calls to `clampToByte()`, one of them inside the counting loop.
