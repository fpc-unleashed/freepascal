# Forced Inlining

In `{$mode unleashed}` the `inline` directive means what it says: every direct call to the routine is expanded inline. No size heuristics decide otherwise and nothing falls back silently. When a call cannot be expanded, the compiler says so with a warning and only then emits a regular call. In every other mode `inline` stays what it always was: a suggestion the compiler is free to ignore.

Three ways to mark a routine: `inline` expands it, `noinline` never expands it, and no directive leaves the decision to the optimizer ([`-OoAUTOINLINE`](optimizations.md#-ooautoinline), on at `-O3`). The optimizer route is not forced: it picks small bodies only and still budgets every call site. The forced regime is entered by one thing alone, the `inline` modifier written on the declaration.

No dedicated modeswitch and no new keyword: the behavior is tied to `{$mode unleashed}` itself.

## Syntax

```pas
function Add3(a, b, c: Integer): Integer; inline;
begin
  Result := a + b + c;
end;

procedure Bump(var x: Integer); inline;
begin
  Inc(x);
end;
```

Works on functions, procedures, methods (non-virtual), and operators.

## Semantics

- **A hand-written `inline` skips the size heuristics.** Stock inlining stops expanding a chain when the estimated code growth gets too large (deep nesting, big bodies). A forced `inline` expands every level unconditionally. You ask for it, you get it, including the code bloat. This never applies to a routine without the modifier: [`-OoAUTOINLINE`](optimizations.md#-ooautoinline) may mark such a routine at `-O3`, but it expands like a stock hint, through the size budget.
- **Definition order does not matter.** A call parsed before the body of the routine is still expanded: code generation of the caller waits until the body has been parsed. That covers a method implemented further down the unit, a routine declared `forward`, and an interface routine whose implementation comes later. This also lifts the stock restriction that `forward` cannot combine with `inline`.
- **`{$inline off}` turns it off**, one routine or one build at a time - see [Turning it off](#turning-it-off).
- **A forced `inline` needs no `-O` level.** It expands at every optimization level, `-O-` and debug builds included, because expansion is gated by `{$inline}` / `-Si` and not by the optimizer. `-OoAUTOINLINE` is an optimizer switch and needs `-O3`.
- **Warning instead of silence.** When an expansion is impossible, a warning names the routine and the reason, and the call is emitted as a regular call. Correctness is never affected; only the call/no-call decision is.
- **The first declaration decides.** `inline` on the interface declaration, on the `forward` declaration, or on the method declaration inside the class/record binds every call. `inline` appearing only on the implementation is accepted for stock compatibility, but it stays a stock-style hint: the declaration promised nothing, so nothing is forced.

## Turning it off

Three ways out, from the widest to the narrowest:

| Way | Scope | Effect |
| --- | ----- | ------ |
| `{$inline off}` | from that point until `{$inline on}` (or end of unit) | at a declaration: the routine falls back to the stock hint; at a call: nothing is expanded there, forced or not |
| `noinline` | one routine | the routine is never inlined; mutually exclusive with `inline` |
| drop `inline` | one routine | back to an ordinary routine |

`{$inline off}` is the switch to reach for when debugging: with the expansions gone, breakpoints and stack traces line up with the source again. The switch is read at two points, each with its own effect.

At a **declaration** it selects the regime per routine:

```pas
{$inline off}
function early(x: integer): integer; inline;   // stock hint - not expanded
begin
  result := x*2;
end;

{$inline on}
function late(x: integer): integer; inline;    // forced again
begin
  result := x*3;
end;
```

A routine degraded this way behaves exactly like stock `inline`. That also means the forced-regime diagnostics go away: a recursive routine declared under `{$inline off}` compiles without the "will not be inlined" warning, because nothing was promised.

At a **call site** it stops every expansion parsed while the switch is off, silently, calls to routines declared forced elsewhere included. Wrap the code being stepped through and every call in it stays a real call:

```pas
{$inline off}
procedure stepping_here;
begin
  x := late(3);   // late is forced above - this call stays a real call
end;
{$inline on}
```

The region switches two more things off. Bodies parsed while it is off are never auto-marked by [`-OoAUTOINLINE`](optimizations.md#-ooautoinline), and calls parsed while it is off do not expand auto-marked routines either. [Procvar Devirtualization](optimizations.md#procvar-devirtualization) stops there as well: a call through a procvar stays indirect, and the store into the variable stays readable in a debugger.

`-Si` is a different matter: `{$mode unleashed}` enables inline support itself, so the mode line re-enables what `-Si-` on the command line switched off. Use `{$inline off}` in the source, not the command-line switch.

## What falls back to a regular call

The forced regime never breaks a build over an impossible expansion - it warns and calls. A recursive routine is the everyday example:

```pas
function fact(n: integer): int64; inline;
begin
  if n < 2 then result := 1 else result := n*fact(n-1);
end;
```

```
demo.pp(3,4) Warning: Routine marked as "inline" will not be inlined: recursion
```

The program compiles and `fact()` works - as a regular call.

Constructs the inliner can never expand are diagnosed on the routine itself (`Warning: Routine marked as "inline" will not be inlined: <reason>`); every call site then uses a regular call:

| Reason | Example |
| ------ | ------- |
| `recursion` | the routine calls itself (cannot expand to a finite tree) |
| `nested procedures` | the body declares a local routine (it reads the parent frame, which is gone once inlined) |
| `nested exit` | `exit(ParentRoutine)` from a nested routine (a subset of the nested-procedures case) |
| `global goto` | a *non-local* goto (iso/mac mode); a normal local goto/label is fine |
| `by-value open array modified in the body` | the parameter is inlined as a reference to the caller's data, so writes would escape the value-copy semantics |
| `access to local from nested scope` | a nested routine reads this routine's locals; the more specific spelling of the nested-procedures case |
| `called C-style varargs functions` | the body calls a `cdecl` routine taking C-style `varargs` |
| `get_frame` | the body reads its own frame pointer via `get_frame()`, and there is no frame of its own once inlined |

Problems visible only at a call site are diagnosed there (`Warning: Call to subroutine "X" marked as "inline" was not inlined: <reason>`), again with a regular call as the fallback:

- **Mutual recursion.** Expanding either body pulls in the other one again, so the expansion is cut off when the depth limit is reached (`the expansion depth limit was reached (mutually recursive inline routines)`). Mark at most one side of a mutually recursive pair as inline to avoid the partial expansion.
- **The body is not available in this compilation.** A `forward` declaration whose implementation never appears, or a routine from a unit whose implementation is not compiled yet (mutually dependent units). Within one unit the definition order is free: a caller parsed before the body simply waits for it.
- **The call cannot be substituted.** It references private symbols from another unit, or a parameter contains a construct the inliner cannot substitute (rare).

`inherited` is supported: a non-virtual inline method that calls `inherited SomeMethod(...)` is expanded correctly, with the self pointer of the inherited call rewritten to the inline self.

A local `goto`/`label` inside the body is fine - labels are relabeled per expansion like any other inline body.

**Open array parameters** are supported, including variadic `array of const`. A `const`/`var array of T` parameter is fed through an address temp at the call site, so the body indexes the caller's data directly. A non-zero-based array (`array[1..10]`) is re-based, a dynamic array is read in place, and an array constructor literal (`[a, b, c]`) works too. The element type may be managed (e.g. `array of string`).

## Assembler statements in Pascal bodies

A Pascal body with embedded `asm ... end;` statements is expandable; stock `inline` rejects any assembler block. Locals and value parameters referenced from the asm get symbol-backed storage per expansion: the asm operands are redirected to it and local labels are renamed. So something like this works and expands fully:

```pas
procedure main; inline;
var
  d: dword;
begin
  asm
    mov [d], 123
  end;
  writeln(d);
end;
```

A by-reference parameter or the function result referenced from the asm block is rejected with a descriptive error; assign through a local instead. This is the one case that stays an error: the problem surfaces when the expansion is already underway, too late for a clean fallback.

## Assembler routines

A pure `assembler` routine can be inlined as long as it is `nostackframe`. Its body is spliced at the call site after the normal parameter marshalling, so the assembler sees its arguments in exactly the registers and stack slots the calling convention would put them in. Hardcoded ABI registers and by-name parameter references both work:

```pas
{$asmmode intel}
function crc32c_step(crc, v: dword): dword; assembler; nostackframe; inline;
asm
  mov   eax, ecx        // win64: ecx = crc
  crc32 eax, edx        //        edx = v
end;
```

Each expansion gets its own copy of the body, with local labels (`@@loop`, ...) renamed per call site, so a routine with internal branches can be inlined many times in one caller. This works across units: the body travels in the PPU.

A framed assembler routine is not spliced, because a framed body references a frame that no longer exists once spliced. The call stays a regular call, with the warning `an assembler routine must be "nostackframe" to be inlined`.

## Taking the address

`@Routine` and assigning to a procvar are allowed; the standalone body is still emitted. A call through the procvar stays indirect only as long as the compiler cannot prove where it points. When the value provably is the address of one routine (a local procvar with a single store, or the address spliced in by inlining a wrapper), the call is [devirtualized](optimizations.md#procvar-devirtualization) into a direct call first, and then expands like any direct call:

```pas
var
  g: TIntFn;        // global

procedure run;
var
  p: TIntFn;        // local, stored once
begin
  x := Twice(5);    // expanded inline - no call instruction
  p := @Twice;
  x := p(7);        // devirtualized into a direct call, then expanded too
  g := @Twice;
  x := g(9);        // a global procvar stays an ordinary indirect call
end;
```

## Declaration conflicts

The directive conflicts are the stock ones: `inline` cannot combine with `virtual`, `external`, `interrupt`, `exports`, `iocheck`, `safecall`, `noinline`, constructors or destructors. A virtual method therefore never enters the forced regime - dynamic dispatch and mandatory expansion do not mix.

## Demo

```pascal
program forced_inline_demo;

{$mode unleashed}

type
  TIntFn = function(x: integer): integer;

  TScaler = class
    factor: integer;
    function scale(x: integer): integer; inline;
    function scaleAndBias(x: integer): integer;
  end;

// the caller comes first; the body of scale is further down the file and
// the expansion still happens - code generation waits for it
function TScaler.scaleAndBias(x: integer): integer;
begin
  result := scale(x)+7;
end;

function TScaler.scale(x: integer): integer;
begin
  result := x*factor;
end;

// forward combines with inline; the call in total precedes the body
function square(x: integer): integer; inline; forward;

function total(x: integer): integer;
begin
  result := square(x)+square(x+1);
end;

function square(x: integer): integer;
begin
  result := x*x;
end;

// recursion cannot be expanded: the compiler warns once at the declaration
// ("will not be inlined: recursion") and every call is a regular call
function fact(n: integer): int64; inline;
begin
  if n < 2 then
    result := 1
  else
    result := n*fact(n-1);
end;

var
  s: TScaler;
  p: TIntFn;

begin
  s := TScaler.Create;
  s.factor := 3;
  writeln('scaleAndBias(10) = ', s.scaleAndBias(10));
  writeln('total(4) = ', total(4));
  writeln('fact(10) = ', fact(10));

  // taking the address is legal - the standalone body still exists; a global
  // procvar stays an ordinary indirect call (a local one would devirtualize)
  p := @square;
  writeln('p(9) = ', p(9));

  s.Free;
  {$ifdef WINDOWS}readln;{$endif}
end.
```

Output:

```
scaleAndBias(10) = 37
total(4) = 41
fact(10) = 3628800
p(9) = 81
```
