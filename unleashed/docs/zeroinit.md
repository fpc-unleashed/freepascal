# `zeroinit` Procedure Modifier

`procedure foo; zeroinit;` zero-initializes every local variable at routine entry. Each local gets an implicit `Default(typeof(local))` assignment inserted at the start of the body, in declaration order, before any user statement runs. The local frame becomes deterministic on entry, exactly as if you had written `:= 0` next to every declaration - and stays that way as locals are added or removed, with no explicit list to maintain.

Available in `{$mode unleashed}`; no separate modeswitch.

## What it does

```pascal
procedure doWork; zeroinit;
var
  i, j: integer;
  s: string;
  r: TPoint;
begin
  // i = 0, j = 0, s = '', r = zero-filled before any statement here
end;
```

- Ordinals become `0`, floats `0.0`, booleans `false`, pointers and class references `nil`.
- Records and static arrays are zero-filled recursively, including inline anonymous compound types (`rec: record a, b: integer; end;`, `arr: array[4] of integer;`).
- Managed locals (`string`, dynamic array, interface, `Variant`) were already initialized by stock FPC; `zeroinit` changes nothing for them.
- The injection happens after tuple destructure assignments have been resolved, so a destructured parameter that writes into a local still wins over the zero.

## Why

By default FPC initializes managed locals but leaves simple types (`integer`, plain records, static arrays) with whatever the stack carries from earlier calls. Most routines dodge the issue by assigning before reading; defensive code, code-generation targets, FFI shims, and one-off prototypes instead lose time hunting "why is this zero sometimes and 0x7FFFA32C other times" bugs. `zeroinit` removes the question.

A side effect that pays off immediately: reads of locals inside a `zeroinit` routine no longer raise `Warning: Local variable "X" does not seem to be initialized` - the locals genuinely are initialized, and the compiler knows it. The same holds for `result`: the `Function result variable (of a managed type) does not seem to be initialized` warnings stay silent too.

## Function result

The function `result` is treated as a regular local and is zeroed too. For unmanaged types (`integer`, records, static arrays) `zeroinit` turns a previously indeterminate pre-assignment value into a guaranteed zero. Managed return types (`string`, dynamic array, interface) are returned through a hidden parameter, and stock FPC may hand the routine the destination's buffer still holding its previous value - `zeroinit` clears it, so `result` is guaranteed empty on entry:

```pascal
function sumFirst(n: integer): integer; zeroinit;
begin
  for var i := 1 to n do result += i; // result starts at 0, accumulate directly
end;
```

## Where it can be applied

Stand-alone procedures and functions, methods on classes and records, constructors and destructors:

```pascal
type
  TCalc = class
    function sum: integer; zeroinit;
  end;

function TCalc.sum: integer;
var
  a, b, c: integer;
begin
  inc(a, 10); inc(b, 20); inc(c, 30);
  result := a+b+c; // = 60, a/b/c started at 0
end;
```

The modifier follows the declaration like any procedure directive and is required only on the declaration (the defining implementation inherits it).

## Where it cannot be applied

Mutually exclusive with `external`, `interrupt`, and `assembler` - those have no Pascal body to inject into. Each combination is rejected with a dedicated diagnostic:

```pascal
procedure doNothing; external 'foo.dll'; zeroinit;
// Error: Procedure directive "ZEROINIT" cannot be used with "EXTERNAL"

procedure asmProc; assembler; zeroinit;
// Error: Procedure directive "ZEROINIT" cannot be used with "ASSEMBLER"
```

## File types: kept on RTL init

A local of a file type (`Text`, `file`, `file of T`), or a compound containing one, is left alone. The RTL entry code already initializes file variables, and their proper closed state is deliberately not all-zeros, so zero-filling would corrupt them. Every other local in the same routine is still zeroed.

## Codegen

`zeroinit` injects ordinary assignment nodes; it does not change the calling convention, stack frame, or register usage. After injection the routine looks to subsequent compilation phases exactly like the user had written the zero-assignments by hand: no runtime helper, no extra symbol, no PPU change beyond a single implprocoption bit on the routine.

## Demo

```pascal
program zeroinit_demo;

{$mode unleashed}

// every local is deterministically zero at entry - no clearing loop needed
procedure printDigitHistogram(const s: string); zeroinit;
var
  bins: array[0..9] of integer;
  total: integer;
begin
  for var ch in s do
    if ch in ['0'..'9'] then begin
      inc(bins[ord(ch)-ord('0')]);
      inc(total);
    end;
  for var d := 0 to 9 do
    if bins[d] > 0 then write($'{d}:{bins[d]} ');
  writeln($'(total {total})');
end;

function sumFirst(n: integer): integer; zeroinit;
begin
  // result starts at 0 even though integer results are normally indeterminate
  for var i := 1 to n do result += i;
end;

begin
  printDigitHistogram('130-870-1120');
  writeln($'sum 1..100 = {sumFirst(100)}');
  {$ifdef WINDOWS}readln;{$endif}
end.
```

Output:

```
0:3 1:3 2:1 3:1 7:1 8:1 (total 10)
sum 1..100 = 5050
```
