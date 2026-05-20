program composable_records_bitpacked_cstyle_word_field_01;

{$mode unleashed}

type
  { same regression with a wider default type }
  TBits = bitpacked record of Word
    a: 7;
    b: 9;
  end;

var
  r: TBits;
begin
  r.a := 100;     { fits in 7 bits, max 127 }
  r.b := 300;     { fits in 9 bits, max 511 }
  if r.a <> 100 then halt(1);
  if r.b <> 300 then halt(2);
  if SizeOf(TBits) <> 2 then halt(3);
end.
