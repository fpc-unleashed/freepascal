{ %OPT="-O4 -OoPARTIALINLINE" }
{ Semantics must be preserved for BOTH arms of the guard when the guard
  argument is a runtime value the compiler cannot fold, and for guards with
  more than one parameter and a class (Assigned) test. Any wrong result Halts
  with a distinct code; exit 0 means every case matched the reference. The
  first landing splits procedures only, so all subjects here are procedures. }
program optpartialinline_semantics_01;
{$mode objfpc}

var
  acc: int64 = 0;

{ plain-exit guard over an ordinal parameter }
procedure AddIfPos(x: longint);
var
  i: longint;
begin
  if x <= 0 then
    exit;
  for i := 1 to x do
    acc := acc + i;
end;

{ guard over two parameters }
procedure AddScaled(x, scale: longint);
begin
  if x <= 0 then
    exit;
  acc := acc + int64(x) * scale;
end;

{ class-pointer (Assigned) guard; the guarded arm does a little work + exit }
procedure Touch(o: TObject; delta: longint);
begin
  if not Assigned(o) then
  begin
    acc := acc - 1;
    exit;
  end;
  acc := acc + delta;
end;

var
  neg, zero, pos, two: longint;
  o: TObject;
begin
  { keep the arguments out of the constant folder's reach }
  neg := -3; zero := 0; pos := 5; two := 2;
  if ParamCount > 1000 then begin neg := 1; zero := 1; pos := 1; two := 1; end;

  AddIfPos(neg);            { guard true  -> no-op }
  AddIfPos(zero);           { guard true  -> no-op }
  AddIfPos(pos);            { guard false -> acc += 15 }
  if acc <> 15 then Halt(1);

  AddScaled(zero, 10);      { guard true  -> no-op }
  AddScaled(pos, two);      { guard false -> acc += 10 }
  if acc <> 25 then Halt(2);

  o := nil;
  Touch(o, 100);            { guard true  -> acc -= 1 (tiny work + exit) }
  if acc <> 24 then Halt(3);
  o := TObject.Create;
  Touch(o, 100);            { guard false -> acc += 100 }
  o.Free;
  if acc <> 124 then Halt(4);
end.
