{ %FAIL }
program strinterp_fail_bad_mask_string_01;
// strings need a `%`-prefixed Format mask; naked 'x' is not supported

{$mode unleashed}

uses sysutils;

var
  name: string;
begin
  name := 'foo';
  writeln($'{name:x}');
end.
