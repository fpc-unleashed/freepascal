{ %OPT=-Sg- }
{ -Sg- turns goto off on the command line; unleashed mode must re-enable it
  so this still compiles without an explicit `{$goto on}` }
program mode_default_switches_goto_01;

{$mode unleashed}

label l;
begin
  goto l;
  halt(1);
l:
end.
