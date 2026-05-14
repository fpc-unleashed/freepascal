program backtick_concat_in_const_01;

{$mode unleashed}

const
  PART1 = `hello`;
  PART2 = `world`;
  COMBO = PART1 + ` ` + PART2;

begin
  if COMBO <> 'hello world' then halt(1);
end.
