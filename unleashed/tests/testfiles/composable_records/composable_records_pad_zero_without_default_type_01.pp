program composable_records_pad_zero_without_default_type_01;

{$mode unleashed}

type
  { `pad 0` without an `of T` default aligns to the next byte
    boundary - default storage unit is one byte when no default
    type is active }
  TPacked = bitpacked record
    a: boolean;
    pad 0;
    b: byte;
  end;

var
  p: TPacked;
begin
  p.a := true;
  p.b := $55;
  if not p.a then halt(1);
  if p.b <> $55 then halt(2);
  { a is 1 bit, pad 0 rounds up to next byte, b lands at offset 1 }
  if SizeOf(p) <> 2 then halt(3);
end.
