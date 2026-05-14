program composable_records_bitpacked_one_bit_bool_01;

{$mode unleashed}

type
  TFlags = bitpacked record of Boolean
    a, b, c, d, e, f, g, h: 1;
  end;

var
  f: TFlags;
begin
  f.a := True;
  f.h := True;
  if not f.a then halt(1);
  if     f.b then halt(2);
  if not f.h then halt(3);
end.
