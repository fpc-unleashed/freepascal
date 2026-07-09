program strinterp_mask_width_01;

{$mode unleashed}

// a plain numeric mask with a nonzero digit is a write-style field width:
// `{x:6}` behaves like write(x:6); `{r:8:2}` like write(r:8:2).
// no SysUtils needed - the value is padded, not formatted
var
  big: SizeInt;
  r: double;
  s, res: string;
begin
  big := 311;
  r := 3.14159;
  s := 'hi';

  res := $'{big:6}';
  if res <> '   311' then halt(1);

  // width smaller than the value: no padding, full value kept
  res := $'{big:2}';
  if res <> '311' then halt(2);

  res := $'{r:8:2}';
  if res <> '    3.14' then halt(3);

  // strings pad too
  res := $'{s:5}';
  if res <> '   hi' then halt(4);

  // several specs in one literal
  res := $'[{big:6}]-[{s:3}]';
  if res <> '[   311]-[ hi]' then halt(5);
end.
