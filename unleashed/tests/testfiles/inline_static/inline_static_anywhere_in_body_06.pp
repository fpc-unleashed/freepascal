program inline_static_anywhere_in_body_06;
{$mode unleashed}

procedure Use(flag: Boolean);
begin
  WriteLn('entering');
  if flag then
  begin
    static touched_count := 0;
    Inc(touched_count);
    if touched_count > 3 then halt(1);
  end;
  WriteLn('done');
end;

begin
  Use(True);
  Use(False);  // does not touch the static
  Use(True);
  Use(True);
end.
