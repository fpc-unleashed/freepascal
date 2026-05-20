program composable_records_union_basic_01;

{$mode unleashed}

type
  TRec = record
    union
      i: LongInt;
      b: array[0..3] of Byte;
    end;
  end;

var
  r: TRec;
begin
  r.i := $04030201;
  if r.b[0] <> $01 then halt(1);
  if r.b[1] <> $02 then halt(2);
  if r.b[2] <> $03 then halt(3);
  if r.b[3] <> $04 then halt(4);
end.
