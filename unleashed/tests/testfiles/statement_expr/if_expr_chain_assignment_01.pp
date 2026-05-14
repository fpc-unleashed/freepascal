program if_expr_chain_assignment_01;

{$mode unleashed}

function Sign(n: Integer): Integer;
begin
  Result := if n > 0 then  1
            else if n < 0 then -1
            else 0;
end;

begin
  if Sign(5)   <>  1 then halt(1);
  if Sign(-5)  <> -1 then halt(2);
  if Sign(0)   <>  0 then halt(3);
end.
