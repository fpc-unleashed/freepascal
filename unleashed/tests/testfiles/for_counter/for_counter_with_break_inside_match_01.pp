program for_counter_with_break_inside_match_01;

{$mode unleashed}

var
  i: Integer;

begin
  for i := 1 to 100 do
  begin
    match i of
      42: break;
      _: ;
    end;
  end;
  // counter holds the break value
  if i <> 42 then halt(1);
end.
