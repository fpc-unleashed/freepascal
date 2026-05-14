program defer_in_match_branch_01;

{$mode unleashed}

var
  trace: String = '';

procedure DoWork(n: Integer);
begin
  match n of
    1: begin
         defer trace := trace + 'D1;';
         trace := trace + 'B1;';
       end;
    2: begin
         defer trace := trace + 'D2;';
         trace := trace + 'B2;';
       end;
    _: begin
         defer trace := trace + 'D_;';
         trace := trace + 'B_;';
       end;
  end;
  trace := trace + 'after;';
end;

begin
  DoWork(1);
  if trace <> 'B1;D1;after;' then halt(1);
  trace := '';
  DoWork(99);
  if trace <> 'B_;D_;after;' then halt(2);
end.
