program inline_static_explicit_type_02;
{$mode unleashed}

procedure Check;
begin
  static x: Integer := 42;
  static s: string := 'hello';
  static z: Integer;
  if x <> 42 then halt(1);
  if s <> 'hello' then halt(2);
  if z <> 0 then halt(3);
end;

begin
  Check;
end.
