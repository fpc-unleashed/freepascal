program parallelfor_var_name_12;
{$mode unleashed}
// `parallel` is only a keyword before `var` or `(`; as a plain variable it
// still drives an ordinary sequential for loop
var parallel, s: Integer;
begin
  s := 0;
  for parallel := 1 to 5 do s := s + parallel;
  if s <> 15 then halt(1);
end.
