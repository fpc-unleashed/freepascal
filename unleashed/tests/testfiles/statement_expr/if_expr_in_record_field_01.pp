program if_expr_in_record_field_01;

{$mode unleashed}

type
  TLog = record
    severity: String;
    code: Integer;
  end;

function MakeLog(c: Integer): TLog;
begin
  Result.severity := if c >= 500 then 'critical'
                     else if c >= 400 then 'error'
                     else if c >= 300 then 'warn'
                     else 'info';
  Result.code := c;
end;

begin
  if MakeLog(200).severity <> 'info'     then halt(1);
  if MakeLog(301).severity <> 'warn'     then halt(2);
  if MakeLog(404).severity <> 'error'    then halt(3);
  if MakeLog(503).severity <> 'critical' then halt(4);
end.
