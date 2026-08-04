{$mode unleashed}
{ test WriteLn auto-expansion of tuples }
program tuple_writeln_expansion_01;

var
  p: (Integer, String);
  t: (Integer, Integer, Integer);
begin
  p := (42, 'hello');
  t := (1, 2, 3);

  { these should compile and run without error }
  WriteLn(p);
  WriteLn(t);
  Write(p);
  WriteLn;

  writeln('ok');
end.
