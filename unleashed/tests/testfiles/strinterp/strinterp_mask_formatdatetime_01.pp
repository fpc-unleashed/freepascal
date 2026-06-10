program strinterp_mask_formatdatetime_01;

{$mode unleashed}

uses sysutils;

var
  dt: TDateTime;
  s: string;
begin
  dt := EncodeDate(2026, 5, 4);
  s := $'{dt:yyyy-mm-dd}';
  if s <> '2026-05-04' then halt(1);

  dt := EncodeDate(2026, 5, 4) + EncodeTime(3, 15, 42, 0);
  s := $'{dt:hh:nn:ss}';
  if s <> '03:15:42' then halt(2);

  s := $'{dt:yyyy-mm-dd hh:nn:ss}';
  if s <> '2026-05-04 03:15:42' then halt(3);
end.
