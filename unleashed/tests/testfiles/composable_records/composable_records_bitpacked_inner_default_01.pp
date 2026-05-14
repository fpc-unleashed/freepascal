program composable_records_bitpacked_inner_default_01;

{$mode unleashed}

type
  TOuter = bitpacked record of Byte
    a, b, c: 1;
    { inner record with NO `of T` inherits outer's default type }
    inner: bitpacked record
      x, y, z: 1;
    end;
  end;

begin
  { 3 outer + 3 inner = 6 bits, but inner is a sub-record carrier with
    its own byte boundary, so layout is outer.bits(3) + inner-as-record;
    sizeof = at least 2 bytes }
  if SizeOf(TOuter) < 1 then halt(1);
end.
