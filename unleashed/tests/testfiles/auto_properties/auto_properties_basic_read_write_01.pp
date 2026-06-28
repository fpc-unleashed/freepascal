program auto_properties_basic_read_write_01;

{$mode unleashed}

type
  TBox = class
    property Name: String;       // auto: read FName write FName
    property Count: Integer;     // auto: read FCount write FCount
  end;

var
  b: TBox;
begin
  b := TBox.Create;
  b.Name := 'hello';
  b.Count := 7;
  if b.Name <> 'hello' then halt(1);
  if b.Count <> 7 then halt(2);
  b.Count := b.Count + 1;
  if b.Count <> 8 then halt(3);
  b.Free;
end.
