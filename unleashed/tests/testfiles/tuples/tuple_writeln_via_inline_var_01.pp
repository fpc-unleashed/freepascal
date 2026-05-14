{ %NORUN }
program tuple_writeln_via_inline_var_01;

{$mode unleashed}

begin
  // syntax-only: tuple bound by inline-var passed to WriteLn
  var t := (1, 2, 'three');
  WriteLn(t);
  var named: (x, y: Integer);
  named.x := 10;
  named.y := 20;
  WriteLn(named);
end.
