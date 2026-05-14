program match_as_expression_in_arg_01;

{$mode unleashed}

uses SysUtils;

function FormatStatus(code: Integer): String;
begin
  Result := Format('%d (%s)',
                   [code,
                    match
                      code >= 500: 'critical';
                      code >= 400: 'error';
                      code >= 300: 'redirect';
                      code >= 200: 'ok';
                      _:           'info';
                    end]);
end;

begin
  if FormatStatus(503) <> '503 (critical)' then halt(1);
  if FormatStatus(404) <> '404 (error)'    then halt(2);
  if FormatStatus(200) <> '200 (ok)'       then halt(3);
end.
