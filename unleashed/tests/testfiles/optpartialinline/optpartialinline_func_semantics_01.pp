{ %OPT="-O4 -OoPARTIALINLINE" }
{ Functions (non-void return) must be split correctly: the guard arm's
  exit(value) and the tail's Result assignment have to land in the SAME result
  location once the header is inlined. This exercises both arms for integer,
  floating-point, enum and pointer results, at call sites that use the result
  in a comparison, in a direct assignment (the funcret-reuse path) and nested
  in an expression. Every wrong result Halts with a distinct code; exit 0 means
  both arms matched the reference for every result type. }
program optpartialinline_func_semantics_01;
{$mode objfpc}

type
  TColor = (cRed, cGreen, cBlue);

var
  coldhits: int64 = 0;

{ integer result; the tail has a side effect so we can also observe that the
  cold path runs exactly once per guard-false call }
function ClampInt(x: longint): longint;
begin
  if x < 0 then
    exit(-1);
  Inc(coldhits);
  Result := x * 2 + 7;
end;

{ floating-point result }
function ScaleF(x: double): double;
begin
  if x = 0.0 then
    exit(0.0);
  Result := x * 3.5 + 1.0;
end;

{ enum result }
function PickColor(n: longint): TColor;
begin
  if n <= 0 then
    exit(cRed);
  Result := cBlue;
end;

{ pointer result; guard branch does a little straight-line work then exits }
function FirstNonNil(p, fallback: pointer): pointer;
var
  tmp: pointer;
begin
  if p <> nil then
  begin
    tmp := p;
    exit(tmp);
  end;
  Result := fallback;
end;

var
  neg, zero, pos: longint;
  fzero, ftwo: double;
  a, b: longint;
  ri: longint;
  rf: double;
  rc: TColor;
  rp: pointer;
begin
  { keep the arguments away from the constant folder }
  neg := -5; zero := 0; pos := 10;
  fzero := 0.0; ftwo := 2.0;
  a := 1; b := 2;
  if ParamCount > 1000 then
  begin
    neg := 1; zero := 1; pos := 1; fzero := 1; ftwo := 1;
  end;

  { integer: guard arm (compare-use) }
  if ClampInt(neg) <> -1 then Halt(1);
  { integer: tail arm (direct assignment / funcret-reuse) }
  ri := ClampInt(pos);
  if ri <> 27 then Halt(2);
  ri := ClampInt(zero);
  if ri <> 7 then Halt(3);

  { float: both arms }
  rf := ScaleF(fzero);
  if rf <> 0.0 then Halt(4);
  rf := ScaleF(ftwo);
  if rf <> 8.0 then Halt(5);

  { enum: both arms, direct assignment }
  rc := PickColor(neg);
  if rc <> cRed then Halt(6);
  rc := PickColor(pos);
  if rc <> cBlue then Halt(7);

  { pointer: both arms }
  rp := FirstNonNil(@a, @b);
  if rp <> @a then Halt(8);
  rp := FirstNonNil(nil, @b);
  if rp <> @b then Halt(9);

  { nested in an expression, both arms in one shot }
  if ClampInt(pos) + ClampInt(neg) <> 26 then Halt(10);

  { cold (tail) path taken by ClampInt for: ClampInt(pos), ClampInt(zero) and
    ClampInt(pos) inside the expression -> 3 times }
  if coldhits <> 3 then Halt(11);
end.
