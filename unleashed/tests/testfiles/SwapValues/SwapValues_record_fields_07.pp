program SwapValues_record_fields_07;
{$mode unleashed}
type
  TPair = record x, y: Integer; end;
var
  p: TPair;
begin
  p.x := 10; p.y := 20;
  SwapValues(p.x, p.y);
  if p.x <> 20 then halt(1);
  if p.y <> 10 then halt(2);
end.
