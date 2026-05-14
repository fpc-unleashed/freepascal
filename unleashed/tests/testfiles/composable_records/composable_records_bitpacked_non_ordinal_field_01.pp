program composable_records_bitpacked_non_ordinal_field_01;

{$mode unleashed}

type
  TBytes3 = array[0..2] of byte;

  { non-ordinal field (here: array) inside a bitpacked record at a
    byte boundary - codegen reads packedbitsize via the type def,
    not via the ordinal-only helper which would IE on arraydef }
  TOverlay = bitpacked record of byte
    a: 3;
    b: 5;
    arr: TBytes3;
  end;

var
  o: TOverlay;
begin
  o.a := 5;
  o.b := 17;
  o.arr[0] := $aa;
  o.arr[1] := $bb;
  o.arr[2] := $cc;
  if o.a <> 5 then halt(1);
  if o.b <> 17 then halt(2);
  if o.arr[0] <> $aa then halt(3);
  if o.arr[1] <> $bb then halt(4);
  if o.arr[2] <> $cc then halt(5);
end.
