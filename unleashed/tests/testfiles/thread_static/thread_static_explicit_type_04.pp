program thread_static_explicit_type_04;
{$mode unleashed}

// explicit type declaration form, with and without initializer
function Check: Boolean;
begin
  threadstatic x: Integer := 42;
  threadstatic s: string := 'hi';
  threadstatic z: Integer;
  Result := (x = 42) and (s = 'hi') and (z = 0);
end;

begin
  if not Check then halt(1);
end.
