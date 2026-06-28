program auto_properties_prefix_multichar_20;

{$mode unleashed}
{$autopropprefix fld_}

// a multi-character prefix is kept verbatim; field is fld_count
type
  TBox = class
    property count: Integer;
    procedure Bump;
  end;

procedure TBox.Bump;
begin
  fld_count := fld_count + 1;
end;

var
  b: TBox;
begin
  b := TBox.Create;
  b.Bump;
  b.Bump;
  if b.count <> 2 then halt(1);
  b.Free;
end.
