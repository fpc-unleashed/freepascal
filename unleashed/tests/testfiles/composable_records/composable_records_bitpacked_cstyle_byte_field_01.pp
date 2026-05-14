program composable_records_bitpacked_cstyle_byte_field_01;

{$mode unleashed}

type
  { C-style `name: N` over Byte default; previously the codegen ignored
    the per-field `custom_bitsize` and used the full type width (8 bits)
    for load / store, corrupting the neighbour bits on every write }
  TBits = bitpacked record of Byte
    a: 3;
    b: 5;
  end;

var
  r: TBits;
begin
  r.a := 5;     { 101 = 5, fits in 3 bits }
  r.b := 17;    { 10001 = 17, fits in 5 bits }
  { the key check: reading r.a after r.b was written must still give 5,
    not the entire byte mashed together }
  if r.a <> 5 then halt(1);
  if r.b <> 17 then halt(2);
  if SizeOf(TBits) <> 1 then halt(3);
end.
