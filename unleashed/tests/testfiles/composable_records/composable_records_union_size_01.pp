program composable_records_union_size_01;

{$mode unleashed}

type
  TRec = record
    union size 8
      a: LongInt;          { 4 bytes }
      b: array[0..3] of Byte;
    end;
  end;

begin
  { size 8 forces the union to occupy 8 bytes, padded beyond the
    largest variant (4 bytes) }
  if SizeOf(TRec) <> 8 then halt(1);
end.
