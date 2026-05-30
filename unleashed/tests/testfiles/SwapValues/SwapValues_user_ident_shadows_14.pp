program SwapValues_user_ident_shadows_14;
{$mode unleashed}
// a user-declared SwapValues shadows the builtin: the parser only takes over SwapValues
// when no symbol of that name is in scope
var
  calls: Integer = 0;

procedure SwapValues(var a, b: Integer);
begin
  Inc(calls);
end;

var
  x, y: Integer;
begin
  x := 1; y := 2;
  SwapValues(x, y);
  if calls <> 1 then halt(1);
  if (x <> 1) or (y <> 2) then halt(2);
end.
