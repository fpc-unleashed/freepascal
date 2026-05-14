program composable_records_subrange_under_of_default_01;

{$mode unleashed}

type
  { `name: Low..High` is a subrange type, not a C-style bitfield
    width - even inside a `bitpacked record of T` where the C-style
    shorthand is normally active. Disambiguated by `..` after the
    leading integer literal. Per-field `bitsize N` still applies. }
  TOverlay = bitpacked record of Byte
    bits: 0..15 bitsize 4;
    flag: 1;
    pad 3;
  end;

var
  o: TOverlay;
begin
  o.bits := 13;
  o.flag := 1;
  if o.bits <> 13 then halt(1);
  if o.flag <> 1 then halt(2);
  if BitSizeOf(o) <> 8 then halt(3);
end.
