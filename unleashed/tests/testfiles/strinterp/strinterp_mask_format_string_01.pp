program strinterp_mask_format_string_01;

{$mode unleashed}

uses sysutils;

var
  name: string;
  s: string;
begin
  name := 'foo';
  s := $'{name:%-10s}|';
  if s <> 'foo       |' then halt(1);

  s := $'{name:%10s}|';
  if s <> '       foo|' then halt(2);

  s := $'{name:%s}';
  if s <> 'foo' then halt(3);
end.
