program compound_on_property_int_01;

{$mode unleashed}

type
  TBox = class
  private
    FN: Integer;
  public
    property N: Integer read FN write FN;
  end;

begin
  var b := autofree TBox.Create;
  b.N := 10;
  b.N += 5;
  if b.N <> 15 then halt(1);
  b.N *= 2;
  if b.N <> 30 then halt(2);
  b.N -= 30;
  if b.N <> 0 then halt(3);
end.
