{ %OPT=--autopropprefix=p_ }
program auto_properties_prefix_cli_19;

{$mode unleashed}

// --autopropprefix=p_ on the command line names the backing field p_value
type
  TBox = class
    property value: Integer;
    procedure SetIt;
  end;

procedure TBox.SetIt;
begin
  p_value := 5;
end;

var
  b: TBox;
begin
  b := TBox.Create;
  b.SetIt;
  if b.value <> 5 then halt(1);
  b.Free;
end.
