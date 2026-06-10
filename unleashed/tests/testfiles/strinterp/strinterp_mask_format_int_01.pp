program strinterp_mask_format_int_01;

{$mode unleashed}

uses sysutils;

var
  n: integer;
  s: string;
begin
  n := 42;
  s := $'{n:%d}';
  if s <> '42' then halt(1);

  s := $'{n:%5d}';
  if s <> '   42' then halt(2);

  s := $'{n:%-5d}|';
  if s <> '42   |' then halt(3);

  s := $'{n:%x}';
  if s <> '2A' then halt(4);
end.
