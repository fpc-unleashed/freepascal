{ %FAIL %OPT="-Sew -vw" }
{ test with-list shadow warning: field hidden by later entry must warn }
{$mode unleashed}

type
  TA = record
    x, y: integer;
  end;
  TB = record
    x, z: integer;
  end;

var
  a: TA;
  b: TB;
begin
  a.x := 1; a.y := 2;
  b.x := 3; b.z := 4;
  with a, b do
    if x <> 3 then
      halt(1);
end.
