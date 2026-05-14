program defer_in_case_branch_01;

{$mode unleashed}

var
  trace: String = '';

procedure DoWork(n: Integer);
begin
  case n of
    1: begin
         defer trace := trace + 'D1;';
         trace := trace + 'B1;';
       end;
    2: begin
         defer trace := trace + 'D2;';
         trace := trace + 'B2;';
       end;
  end;
  trace := trace + 'end;';
end;

begin
  DoWork(1);
  if trace <> 'B1;D1;end;' then halt(1);
  trace := '';
  DoWork(2);
  if trace <> 'B2;D2;end;' then halt(2);
end.
