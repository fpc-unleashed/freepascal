program strinterp_mask_inttohex_01;

{$mode unleashed}

uses sysutils;

var
  n: integer;
  s: string;
begin
  n := 255;
  s := $'{n:x2}';
  if s <> 'FF' then halt(1);

  s := $'{n:x4}';
  if s <> '00FF' then halt(2);

  s := $'{16:x8}';
  if s <> '00000010' then halt(3);

  // single-char mask 'x' = hex with 0 padding (just hex digits)
  s := $'{n:x}';
  if s <> 'FF' then halt(4);
end.
