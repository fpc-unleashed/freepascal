program match_in_function_returning_tuple_01;

{$mode unleashed}

function HttpStatus(code: Integer): (kind: String; transient: Boolean);
begin
  match
    code >= 500: Result := (kind: 'server', transient: true);
    code >= 400: Result := (kind: 'client', transient: false);
    code >= 300: Result := (kind: 'redirect', transient: false);
    code >= 200: Result := (kind: 'ok', transient: false);
    _:           Result := (kind: 'info', transient: false);
  end;
end;

begin
  var s := HttpStatus(503);
  if s.kind <> 'server' then halt(1);
  if not s.transient    then halt(2);

  s := HttpStatus(404);
  if s.kind <> 'client' then halt(3);
  if s.transient        then halt(4);

  s := HttpStatus(200);
  if s.kind <> 'ok'     then halt(5);
end.
