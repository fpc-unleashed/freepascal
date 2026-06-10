{ %FAIL }
program strinterp_fail_no_sysutils_datetime_01;
// TDateTime/TDate/TTime are in `system`, but FormatDateTime is in SysUtils;
// the error must point at the missing FormatDateTime, not the generic bad_type

{$mode unleashed}

// note: SysUtils intentionally not in uses

var
  dt: TDateTime;
  d: TDate;
  t: TTime;
begin
  dt := 0; d := 0; t := 0;
  writeln($'{dt:yyyy-mm-dd}');
  writeln($'{d:yyyy-mm-dd}');
  writeln($'{t:hh:nn:ss}');
end.
