{$mode unleashed}
{ test constant-index access on tuples }
program tuple_const_index_access_01;

var
  p: (Integer, String);
  t: (Integer, Integer, Integer);
begin
  p := (42, 'hello');
  t := (10, 20, 30);

  { 0-based index access }
  if p[0] <> 42 then halt(1);
  if p[1] <> 'hello' then halt(2);

  if t[0] <> 10 then halt(3);
  if t[1] <> 20 then halt(4);
  if t[2] <> 30 then halt(5);

  { index access is same as _N access }
  if p[0] <> p._1 then halt(6);
  if p[1] <> p._2 then halt(7);
  if t[0] <> t._1 then halt(8);

  writeln('ok');
end.
