program match_in_inner_function_01;

{$mode unleashed}

function Outer(n: Integer): String;

  function Inner(m: Integer): String;
  begin
    match m of
      0:    Result := 'zero';
      1..9: Result := 'tiny';
      _:    Result := 'big';
    end;
  end;

begin
  Result := Inner(n);
end;

begin
  if Outer(0)   <> 'zero' then halt(1);
  if Outer(5)   <> 'tiny' then halt(2);
  if Outer(100) <> 'big'  then halt(3);
end.
