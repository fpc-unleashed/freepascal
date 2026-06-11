{ %OPT=-Sc- }
{ -Sc- turns C-style assignment operators off on the command line; unleashed
  mode must re-enable them so `+=` / `*=` still compile }
program mode_default_switches_coperators_01;

{$mode unleashed}

var
  i: Integer;
begin
  i := 10;
  i += 5;
  i *= 2;
  if i <> 30 then halt(1);
end.
