{ %FAIL }
program strinterp_fail_no_sysutils_01;
// mask dispatch needs SysUtils for Format / FormatFloat / IntToHex

{$mode unleashed}

// note: SysUtils intentionally not in uses

var
  n: integer;
begin
  n := 42;
  writeln($'{n:%d}');
end.
