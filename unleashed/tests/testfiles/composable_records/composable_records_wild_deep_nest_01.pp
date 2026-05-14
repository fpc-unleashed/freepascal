program composable_records_wild_deep_nest_01;

{$mode unleashed}

type
  TL1 = record a: Byte; end;
  TL2 = record embed TL1; b: Byte; end;
  TL3 = record embed TL2; c: Byte; end;
  TL4 = record embed TL3; d: Byte; end;

var
  r: TL4;
begin
  r.a := 1;
  r.b := 2;
  r.c := 3;
  r.d := 4;
  if r.a <> 1 then halt(1);
  if r.b <> 2 then halt(2);
  if r.c <> 3 then halt(3);
  if r.d <> 4 then halt(4);
end.
