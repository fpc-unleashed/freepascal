program thread_static_section_before_var_15;
{$mode unleashed}

// the threadstatic section may be followed by a regular var section; the
// section keyword stops at the `var` hard token. (a var section must not
// precede it - that would swallow the soft `threadstatic` identifier.)
function F: Integer;
threadstatic
  kept: Integer = 0;
var
  scratch: Integer;
begin
  scratch := 10;
  Inc(kept);
  Result := kept * 100 + scratch;
end;

begin
  if F <> 110 then halt(1);   // kept=1, scratch=10
  if F <> 210 then halt(2);   // kept=2 (persists), scratch=10 (fresh)
end.
