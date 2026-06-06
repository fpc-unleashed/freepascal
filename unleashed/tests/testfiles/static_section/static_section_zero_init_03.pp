program static_section_zero_init_03;
{$mode unleashed}

procedure Check;
static
  i: Integer;
  b: Boolean;
  s: string;
  p: Pointer;
  d: Double;
begin
  if i <> 0 then halt(1);
  if b then halt(2);
  if s <> '' then halt(3);
  if p <> nil then halt(4);
  if d <> 0.0 then halt(5);
end;

begin
  Check;
end.
