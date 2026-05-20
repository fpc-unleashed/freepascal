program composable_records_perfield_multi_id_01;

{$mode unleashed}

type
  TBits = bitpacked record of Byte
    a, b, c: 1 bitalign 8;        { applies to each of a, b, c individually }
  end;

begin
  { each is 1 bit but bitalign 8 pads each one to its own byte;
    layout = byte for a (1 used) + byte for b + byte for c = 3 bytes }
  if SizeOf(TBits) <> 3 then halt(1);
end.
