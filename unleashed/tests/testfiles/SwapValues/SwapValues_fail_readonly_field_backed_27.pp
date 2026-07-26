{ %FAIL }
program SwapValues_fail_readonly_field_backed_27;
{$mode unleashed}
// a read-only field-backed property is not writable either
type
  TBox = class
  public
    FA: Integer;
    property A: Integer read FA;
  end;

var
  b: TBox;
  x: Integer;
begin
  b := TBox.Create;
  x := 1;
  SwapValues(b.A, x);
  b.Free;
end.
