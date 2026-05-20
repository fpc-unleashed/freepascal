program composable_records_intrinsic_on_variable_01;

{$mode unleashed}

type
  TFoo = bitpacked record of Byte
    a: 3;
    b: 5;
  end;

  TBar = record
    x: Byte;
    y: LongInt align 16;
  end;

var
  v: TFoo;
  b: TBar;
begin
  { AlignOf/BitAlignOf must accept a variable as the operand, not
    only a typename - the variable's type stands in for the type. }
  if AlignOf(v) <> 1 then halt(1);
  if BitAlignOf(v) <> 8 then halt(2);
  if AlignOf(b) <> 16 then halt(3);
  if BitAlignOf(b) <> 128 then halt(4);

  { field path through a variable honours per-field `align N` }
  if AlignOf(b.x) <> 1 then halt(5);
  if AlignOf(b.y) <> 16 then halt(6);
  if BitAlignOf(b.y) <> 128 then halt(7);

  { BitSizeOf is stock-FPC and reads `custom_bitsize` via field path }
  if BitSizeOf(v.a) <> 3 then halt(8);
  if BitSizeOf(v.b) <> 5 then halt(9);
end.
