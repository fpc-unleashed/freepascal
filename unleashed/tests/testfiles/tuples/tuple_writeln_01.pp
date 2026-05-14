{ %NORUN }
program tuple_writeln_01;

{$mode unleashed}

begin
  // tuples can be passed to WriteLn directly (auto-formats fields by comma)
  var t := (42, 'hello');
  WriteLn(t);
  var p: (x, y: Integer);
  p.x := 1; p.y := 2;
  WriteLn(p);
end.
