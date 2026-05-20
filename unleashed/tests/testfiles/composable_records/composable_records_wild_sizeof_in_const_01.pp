program composable_records_wild_sizeof_in_const_01;

{$mode unleashed}

type
  TRec = packed record
    a, b, c, d: Byte;
  end;

const
  Sz = SizeOf(TRec);
  Buf: array[0..Sz - 1] of Byte = (0, 0, 0, 0);

begin
  if Sz <> 4 then halt(1);
  if Length(Buf) <> 4 then halt(2);
end.
