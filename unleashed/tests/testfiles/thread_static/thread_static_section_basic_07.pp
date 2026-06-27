program thread_static_section_basic_07;
{$mode unleashed}

// section form: `threadstatic` declaration section before the body,
// parallel to var/const. single-thread it behaves like a program-wide
// counter that persists across calls.
function Next: Integer;
threadstatic
  n: Integer = 100;
begin
  Inc(n);
  Result := n;
end;

begin
  if Next <> 101 then halt(1);
  if Next <> 102 then halt(2);
  if Next <> 103 then halt(3);
end.
