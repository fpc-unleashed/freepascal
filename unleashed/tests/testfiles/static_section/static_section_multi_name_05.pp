program static_section_multi_name_05;
{$mode unleashed}

procedure Check;
static
  a, b, c: Integer = 7;   // multi-name with shared typed-const value
  x, y: string;            // multi-name zero-init
begin
  if a <> 7 then halt(1);
  if b <> 7 then halt(2);
  if c <> 7 then halt(3);
  if x <> '' then halt(4);
  if y <> '' then halt(5);
end;

begin
  Check;
end.
