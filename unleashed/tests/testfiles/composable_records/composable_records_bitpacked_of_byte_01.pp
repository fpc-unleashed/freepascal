program composable_records_bitpacked_of_byte_01;

{$mode unleashed}

type
  { `of Boolean` makes the C-style `a, b, ...: 1` produce 1-bit Boolean
    fields. Single-bit access through the bit-pack codegen is the
    reliable path; wider sub-byte fields are tracked separately. }
  TBits = bitpacked record of Boolean
    a, b, c, d, e, f, g, h: 1;
  end;

var
  r: TBits;
begin
  r.a := True;
  r.h := True;
  if not r.a then halt(1);
  if     r.b then halt(2);
  if not r.h then halt(3);
  if SizeOf(TBits) <> 1 then halt(4);
end.
