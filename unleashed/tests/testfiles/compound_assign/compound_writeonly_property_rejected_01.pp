{ %FAIL }
program compound_writeonly_property_rejected_01;

{$mode unleashed}

type
  TBox = class
  private
    FN: Integer;
    procedure SetN(v: Integer);
  public
    property N: Integer write SetN;   // write-only
  end;

procedure TBox.SetN(v: Integer);
begin
  FN := v;
end;

begin
  var b := autofree TBox.Create;
  // compound assign needs a getter; write-only property is rejected
  b.N += 5;
end.
