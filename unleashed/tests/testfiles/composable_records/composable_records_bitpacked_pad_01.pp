program composable_records_bitpacked_pad_01;

{$mode unleashed}

type
  TBits = bitpacked record of Boolean
    a, b, c: 1;
    pad 2;             { 2 bits of anonymous padding }
    d, e, f: 1;
  end;

begin
  { 3 + 2 (pad) + 3 = 8 bits -> 1 byte }
  if SizeOf(TBits) <> 1 then halt(1);
end.
