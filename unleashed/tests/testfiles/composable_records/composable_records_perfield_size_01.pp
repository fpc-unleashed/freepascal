program composable_records_perfield_size_01;

{$mode unleashed}

type
  TRec = packed record
    a: Byte size 4;           { byte field padded to 4-byte slot }
    b: Byte;
  end;

begin
  if SizeOf(TRec) <> 5 then halt(1);
end.
