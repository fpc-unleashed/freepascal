program composable_records_union_of_byte_01;

{$mode unleashed}

type
  TRec = record
    union of Byte
      a: Byte;
      b: array[0..0] of Byte;
    end;
  end;

begin
  { `of Byte` gives size=1, align=1; the union must occupy exactly 1 byte }
  if SizeOf(TRec) <> 1 then halt(1);
end.
