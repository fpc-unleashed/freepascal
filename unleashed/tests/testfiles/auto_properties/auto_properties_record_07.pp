program auto_properties_record_07;

{$mode unleashed}

// advanced records support auto-properties too: the backing field is an
// ordinary record field
type
  TWidget = record
    property Tag: String;
    property Size: Integer;
  end;

var
  w: TWidget;
begin
  w.Tag := 'button';
  w.Size := 24;
  if w.Tag <> 'button' then halt(1);
  if w.Size <> 24 then halt(2);
  w.Size := w.Size * 2;
  if w.Size <> 48 then halt(3);
end.
