program composable_records_intrinsic_sizeof_01;

{$mode unleashed}

type
  TBits = bitpacked record of Byte size 4
    a, b, c: 1;
  end;

begin
  { explicit `size 4` makes the record 4 bytes regardless of bit payload }
  if SizeOf(TBits) <> 4 then halt(1);
end.
