program strinterp_mask_formatfloat_01;

{$mode unleashed}

uses sysutils;

var
  f: double;
  s: string;
begin
  f := 1234.5;
  // invariant default: '.' decimal regardless of system locale
  s := $'{f:0.00}';
  if s <> '1234.50' then halt(1);

  s := $'{f:0.0000}';
  if s <> '1234.5000' then halt(2);

  f := 0.5;
  s := $'{f:0.00}';
  if s <> '0.50' then halt(3);
end.
