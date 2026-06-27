program thread_static_section_zero_init_09;
{$mode unleashed}

// section form without initializer: per-thread BSS zero-init, including
// managed types (string starts empty, finalized by the RTL).
function Check: Boolean;
threadstatic
  i: Integer;
  s: string;
  p: Pointer;
begin
  Result := (i = 0) and (s = '') and (p = nil);
  Inc(i);
  s := s + 'x';
end;

begin
  // every call sees the same per-thread slot; first call: all zero
  if not Check then halt(1);
end.
