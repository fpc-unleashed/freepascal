{ %OPT="-Sew -vw" }
{ test with-list shadow warning: distinct field names must not warn }
{$mode unleashed}

type
  TA = record
    a1, a2: integer;
  end;
  TB = record
    b1, b2: integer;
  end;

var
  a: TA;
  b: TB;
  s: integer;
begin
  a.a1 := 1; a.a2 := 2;
  b.b1 := 3; b.b2 := 4;
  s := 0;
  with a, b do
    s := a1 + a2 + b1 + b2;
  if s <> 10 then
    halt(1);
end.
