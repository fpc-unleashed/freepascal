program match_else_branch_01;

{$mode unleashed}

function Bucket(n: Integer): String;
begin
  match n of
    1, 2: Result := 'low';
    3, 4: Result := 'mid';
  else
    Result := 'high';
  end;
end;

begin
  if Bucket(1)   <> 'low'  then halt(1);
  if Bucket(3)   <> 'mid'  then halt(2);
  if Bucket(99)  <> 'high' then halt(3);
end.
