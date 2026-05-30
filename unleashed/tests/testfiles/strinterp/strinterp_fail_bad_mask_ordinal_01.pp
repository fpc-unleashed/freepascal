{ %FAIL }
program strinterp_fail_bad_mask_ordinal_01;
// ordinals only support %-prefixed masks or hex `xN`/`XN`

{$mode unleashed}

uses sysutils;

var
  n: integer;
begin
  n := 42;
  writeln($'{n:d}');
end.
