program compound_div_mod_01;

{$mode unleashed}

begin
  var a := 100;
  a div= 3;
  if a <> 33 then halt(1);

  a := 100;
  a mod= 7;
  if a <> 2 then halt(2);
end.
