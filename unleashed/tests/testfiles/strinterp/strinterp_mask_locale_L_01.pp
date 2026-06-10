program strinterp_mask_locale_L_01;

{$mode unleashed}

uses sysutils;

var
  f: double;
  s, expected: string;
begin
  f := 1234.5;
  // invariant locale (default) - always '.' decimal
  s := $'{f:0.00}';
  if s <> '1234.50' then halt(1);

  // 'L' prefix opts into DefaultFormatSettings - just check it matches
  // FormatFloat with the same mask, regardless of host locale
  expected := FormatFloat('0.00', f);
  s := $'{f:L0.00}';
  if s <> expected then halt(2);

  // L on Format mask still goes through Format (Format's `%.2f` is
  // locale-invariant by design, so L has no visible effect here)
  s := $'{f:%.2f}';
  if s <> '1234.50' then halt(3);
end.
