program composable_records_pad_without_default_type_01;

{$mode unleashed}

type
  TBytes3 = array[0..2] of byte;

  { `pad N` works in a bitpacked record without an `of T` default -
    storage unit defaults to a byte, the pad slot is just N bits }
  TOverlay = bitpacked record
    a: byte;
    pad 4;
    arr: TBytes3;
  end;

var
  o: TOverlay;
begin
  o.a := $aa;
  o.arr[0] := $11;
  o.arr[1] := $22;
  o.arr[2] := $33;
  if o.a <> $aa then halt(1);
  if o.arr[0] <> $11 then halt(2);
  if o.arr[1] <> $22 then halt(3);
  if o.arr[2] <> $33 then halt(4);
end.
