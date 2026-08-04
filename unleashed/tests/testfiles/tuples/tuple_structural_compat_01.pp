{$mode unleashed}
{ test structural compatibility between positional and named tuples }
program tuple_structural_compat_01;

function GetPositional: (Integer, Integer);
begin
  Result := (10, 20);
end;

function GetNamed: (x, y: Integer);
begin
  Result := (x: 30, y: 40);
end;

procedure TakeNamed(p: (a, b: Integer));
begin
  if (p.a <> 10) or (p.b <> 20) then halt(1);
end;

procedure TakePositional(p: (Integer, Integer));
begin
  if (p._1 <> 30) or (p._2 <> 40) then halt(2);
end;

var
  named: (a, b: Integer);
  positional: (Integer, Integer);
begin
  { positional assigned to named }
  named := GetPositional;
  if (named.a <> 10) or (named.b <> 20) then halt(3);

  { named assigned to positional }
  positional := GetNamed;
  if (positional._1 <> 30) or (positional._2 <> 40) then halt(4);

  { positional literal to named parameter }
  TakeNamed((10, 20));

  { named return to positional parameter }
  TakePositional(GetNamed);

  { cross-comparison }
  named := (a: 5, b: 10);
  positional := (5, 10);
  if not (named = positional) then halt(5);
  if named <> positional then halt(6);

  writeln('ok');
end.
