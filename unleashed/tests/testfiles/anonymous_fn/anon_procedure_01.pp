program anon_procedure_01;

{$mode unleashed}

type
  TAction = reference to procedure;

var
  hits: Integer = 0;

begin
  var action: TAction := procedure begin Inc(hits, 5); end;
  action;
  action;
  action;
  if hits <> 15 then halt(1);
end.
