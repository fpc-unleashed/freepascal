program composable_records_typed_const_union_01;

{$mode unleashed}

type
  TIPv4 = record
    union
      whole: LongWord;
      octets: array[0..3] of Byte;
    end;
  end;

const
  k: TIPv4 = (whole: $11223344);

begin
  if k.whole <> $11223344 then halt(1);
  { little-endian read through union overlay }
  if k.octets[0] <> $44 then halt(2);
  if k.octets[3] <> $11 then halt(3);
end.
