program forstep_step_as_identifier_01;

{$mode unleashed}

// `step` is context-sensitive; only a keyword between for-bound and `do`.
// Elsewhere it remains an ordinary identifier.
var
  step: Integer;

function step_fn(n: Integer): Integer;
begin
  Result := n + 1;
end;

begin
  step := 5;
  if step <> 5 then halt(1);
  if step_fn(10) <> 11 then halt(2);

  for var i := 0 to step step 1 do
    ;
end.
