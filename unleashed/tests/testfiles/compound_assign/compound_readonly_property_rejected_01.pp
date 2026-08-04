{ %FAIL }
{ compound assignment and inc/dec on a read-only property must report
  type_e_property_no_writer rather than the stock 'Variable identifier expected'
  or 'Cannot take the address of constant expressions' }
program compound_readonly_property_rejected_01;

{$mode unleashed}

type
  TFoo = class
  private
    FN: integer;
    function GetN: integer;
  public
    property N: integer read GetN;
  end;

function TFoo.GetN: integer;
begin
  Result := FN;
end;

var f: TFoo;
begin
  f := TFoo.Create;
  f.N += 1;
  f.Free;
end.
