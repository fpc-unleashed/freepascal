program defer_in_anonymous_function_01;

{$mode unleashed}

type
  TAction = reference to procedure;

var
  trace: String = '';

begin
  var a: TAction := procedure
                    begin
                      defer trace := trace + 'cleanup;';
                      trace := trace + 'body;';
                    end;
  a;
  if trace <> 'body;cleanup;' then halt(1);
  trace := '';
  a;
  if trace <> 'body;cleanup;' then halt(2);
end.
