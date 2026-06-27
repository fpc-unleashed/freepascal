program thread_static_section_mixed_inline_12;
{$mode unleashed}

// a routine may use both the section form (before the body) and the
// inline form (inside the body); both share the same per-thread storage
// and guard machinery.
function Run: Integer;
threadstatic
  fromsection: Integer = 10;
begin
  threadstatic frominline := 20;
  Inc(fromsection);
  Inc(frominline);
  Result := fromsection * 100 + frominline;
end;

begin
  // section 11, inline 21 -> 1121 ; section 12, inline 22 -> 1222
  if Run <> 1121 then halt(1);
  if Run <> 1222 then halt(2);
end.
