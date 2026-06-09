program strinterp_mask_int_numeric_01;

{$mode unleashed}

uses sysutils;

var
  z: integer;
  s: string;
begin
  z := 123;
  // bare `0` mask = the integer itself (FormatFloat dispatch)
  s := $'{z:0}';
  if s <> '123' then halt(1);

  // zero-padding via `000`
  s := $'{7:000}';
  if s <> '007' then halt(2);

  // fractional mask promotes the integer to a float
  s := $'{z:0.00}';
  if s <> '123.00' then halt(3);

  // thousand separator (invariant locale uses ',')
  s := $'{1234567:#,##0}';
  if s <> '1,234,567' then halt(4);

  // hex still wins for `x`/`X` masks
  s := $'{z:x4}';
  if s <> '007B' then halt(5);

  // `%` masks still go through Format
  s := $'{z:%d}';
  if s <> '123' then halt(6);
end.
