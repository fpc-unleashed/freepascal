{ %OPT=-Seh }
program SwapValues_property_field_backed_inplace_21;
{$mode unleashed}
// properties reading and writing the same field swap in place; -Seh turns
// the not-in-place hint into an error, so passing proves the routing
type
  TBox = class
  public
    FA, FB: Integer;
    property A: Integer read FA write FA;
    property B: Integer read FB write FB;
  end;

var
  b: TBox;
  x: Integer;
begin
  b := TBox.Create;
  b.FA := 1;
  b.FB := 2;
  SwapValues(b.A, b.B);
  if b.FA <> 2 then halt(1);
  if b.FB <> 1 then halt(2);
  x := 3;
  SwapValues(b.A, x);
  if b.FA <> 3 then halt(3);
  if x <> 2 then halt(4);
  b.Free;
end.
