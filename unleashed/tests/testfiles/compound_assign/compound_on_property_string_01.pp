program compound_on_property_string_01;

{$mode unleashed}

type
  TFoo = class
  private
    FName: String;
  public
    property Name: String read FName write FName;
  end;

begin
  var f := autofree TFoo.Create;
  f.Name := 'hello';
  f.Name += ' world';
  if f.Name <> 'hello world' then halt(1);
end.
