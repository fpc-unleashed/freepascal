{$mode unleashed}
{ test underscores in destructured parameter names (bug fix) }
program tuple_param_destructure_underscore_names_01;

procedure ShowNames((first_name, last_name): (String, String));
begin
  if first_name <> 'John' then halt(1);
  if last_name <> 'Doe' then halt(2);
end;

procedure ShowMulti((my_var, count_it, some_val): (Integer, Integer, Integer));
begin
  if my_var <> 10 then halt(3);
  if count_it <> 20 then halt(4);
  if some_val <> 30 then halt(5);
end;

procedure InlineNames((user_id, user_name: Integer));
begin
  if user_id <> 100 then halt(6);
  if user_name <> 200 then halt(7);
end;

begin
  ShowNames(('John', 'Doe'));
  ShowMulti((10, 20, 30));
  InlineNames((100, 200));
  writeln('ok');
end.
