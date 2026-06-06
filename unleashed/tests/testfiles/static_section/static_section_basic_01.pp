program static_section_basic_01;
{$mode unleashed}

procedure Bumper;
static
  cnt: Integer = 0;
  greet: string = 'hi';
begin
  Inc(cnt);
  if greet <> 'hi' then halt(1);
end;

var
  i: Integer;
begin
  for i := 1 to 5 do
    Bumper;
end.
