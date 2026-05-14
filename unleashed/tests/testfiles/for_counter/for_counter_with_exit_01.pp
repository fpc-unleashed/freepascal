program for_counter_with_exit_01;

{$mode unleashed}

var
  saved_i: Integer = -1;

procedure Search;
var
  i: Integer;
begin
  for i := 1 to 50 do
  begin
    if i = 17 then
    begin
      saved_i := i;
      Exit;
    end;
  end;
end;

begin
  Search;
  if saved_i <> 17 then halt(1);
end.
