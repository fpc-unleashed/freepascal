program match_with_negative_subjects_01;

{$mode unleashed}

function Sign(n: Integer): Integer;
begin
  match
    n <  0: Result := -1;
    n =  0: Result := 0;
    n >  0: Result := 1;
  end;
end;

begin
  if Sign(-100) <> -1 then halt(1);
  if Sign(0)    <>  0 then halt(2);
  if Sign(7)    <>  1 then halt(3);
end.
