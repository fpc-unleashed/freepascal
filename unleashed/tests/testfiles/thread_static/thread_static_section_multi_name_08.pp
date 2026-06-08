program thread_static_section_multi_name_08;
{$mode unleashed}

// multi-name section: `a, b, c: Integer = 5` gives each name its own
// per-thread copy, all starting at 5; assigning one must not touch the
// others (independent storage).
function Step: Integer;
threadstatic
  a, b, c: Integer = 5;
begin
  Inc(a);
  Inc(b, 2);
  Inc(c, 3);
  Result := a * 100 + b * 10 + c;
end;

begin
  // a=6 b=7 c=8 -> 678 ; a=7 b=9 c=11 -> 7*100+9*10+11 = 801
  if Step <> 678 then halt(1);
  if Step <> 801 then halt(2);
end.
