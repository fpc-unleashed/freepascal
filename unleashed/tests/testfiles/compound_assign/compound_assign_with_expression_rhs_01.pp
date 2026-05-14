program compound_assign_with_expression_rhs_01;

{$mode unleashed}

function Two: Integer;
begin
  Result := 2;
end;

begin
  var n := 10;
  n += Two * 5;        // = 10 + (2*5) = 20
  if n <> 20 then halt(1);
  n -= Two + 3;        // = 20 - (2+3) = 15
  if n <> 15 then halt(2);
  n *= Two;            // = 15 * 2 = 30
  if n <> 30 then halt(3);
end.
