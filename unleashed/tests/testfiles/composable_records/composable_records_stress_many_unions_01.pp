program composable_records_stress_many_unions_01;

{$mode unleashed}

type
  TMany = record
    union a: LongWord; b: array[0..3] of Byte; end;
    union c: LongWord; d: array[0..3] of Byte; end;
    union e: LongWord; f: array[0..3] of Byte; end;
    union g: LongWord; h: array[0..3] of Byte; end;
    union i: LongWord; j: array[0..3] of Byte; end;
  end;

var
  m: TMany;
begin
  m.a := $11111111;
  m.c := $22222222;
  m.e := $33333333;
  m.g := $44444444;
  m.i := $55555555;
  if m.b[0] <> $11 then halt(1);
  if m.d[0] <> $22 then halt(2);
  if m.f[0] <> $33 then halt(3);
  if m.h[0] <> $44 then halt(4);
  if m.j[0] <> $55 then halt(5);
end.
