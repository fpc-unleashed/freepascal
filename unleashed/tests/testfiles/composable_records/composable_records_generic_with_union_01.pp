program composable_records_generic_with_union_01;

{$mode unleashed}

type
  generic TPair<T> = record
    first: T;
    union
      raw: array[0..7] of Byte;
      record
        lo, hi: LongWord;
      end;
    end;
  end;

var
  p: specialize TPair<Byte>;
begin
  p.first := 7;
  p.lo := $11223344;
  p.hi := $55667788;
  if p.first <> 7 then halt(1);
  if p.raw[0] <> $44 then halt(2);
  if p.raw[4] <> $88 then halt(3);
end.
