{ %OPT=-dSANITY_DEFINE }
program sanity_opt_passed_01;

{$mode unleashed}

begin
  // verify testtool propagates %OPT to the compiler:
  // -dSANITY_DEFINE must be visible to {$ifdef ...}
  {$ifndef SANITY_DEFINE}
  halt(1);
  {$endif}

  var sum := 0;
  for var i := 1 to 100 do
    sum := sum + i;
  if sum <> 5050 then halt(2);
end.
