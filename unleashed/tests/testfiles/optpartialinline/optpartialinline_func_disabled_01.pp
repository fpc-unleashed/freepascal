{ %OPT="-O4 -OoNOPARTIALINLINE" }
{ Baseline control for optpartialinline_func_semantics_01: the very same
  function subjects and assertions, but with the split pass OFF. The results
  must be identical to the switched-on run -- this pins that enabling
  -OoPARTIALINLINE does not change observable function semantics. Wrong results
  Halt with a distinct code. }
program optpartialinline_func_disabled_01;
{$mode objfpc}

type
  TColor = (cRed, cGreen, cBlue);

var
  coldhits: int64 = 0;

function ClampInt(x: longint): longint;
begin
  if x < 0 then
    exit(-1);
  Inc(coldhits);
  Result := x * 2 + 7;
end;

function ScaleF(x: double): double;
begin
  if x = 0.0 then
    exit(0.0);
  Result := x * 3.5 + 1.0;
end;

function PickColor(n: longint): TColor;
begin
  if n <= 0 then
    exit(cRed);
  Result := cBlue;
end;

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
  neg := -5; zero := 0; pos := 10;
  fzero := 0.0; ftwo := 2.0;
  a := 1; b := 2;
  if ParamCount > 1000 then
  begin
    neg := 1; zero := 1; pos := 1; fzero := 1; ftwo := 1;
  end;

  if ClampInt(neg) <> -1 then Halt(1);
  ri := ClampInt(pos);
  if ri <> 27 then Halt(2);
  ri := ClampInt(zero);
  if ri <> 7 then Halt(3);

  rf := ScaleF(fzero);
  if rf <> 0.0 then Halt(4);
  rf := ScaleF(ftwo);
  if rf <> 8.0 then Halt(5);

  rc := PickColor(neg);
  if rc <> cRed then Halt(6);
  rc := PickColor(pos);
  if rc <> cBlue then Halt(7);

  rp := FirstNonNil(@a, @b);
  if rp <> @a then Halt(8);
  rp := FirstNonNil(nil, @b);
  if rp <> @b then Halt(9);

  if ClampInt(pos) + ClampInt(neg) <> 26 then Halt(10);

  if coldhits <> 3 then Halt(11);
end.
