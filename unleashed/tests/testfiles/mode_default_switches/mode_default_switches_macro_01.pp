{ macro support is on by default in unleashed mode, so the parameterized
  define form is available without an explicit `$macro on` switch }
program mode_default_switches_macro_01;

{$mode unleashed}
{$define greeting := 'hello'}

begin
  if greeting <> 'hello' then halt(1);
end.
