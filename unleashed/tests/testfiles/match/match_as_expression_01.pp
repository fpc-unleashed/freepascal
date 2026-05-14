program match_as_expression_01;

{$mode unleashed}

begin
  for var n := 1 to 5 do
  begin
    var s := match n of
      1: 'one';
      2: 'two';
      _: 'other';
    end;
    case n of
      1: if s <> 'one'   then halt(n);
      2: if s <> 'two'   then halt(n);
    else
      if s <> 'other' then halt(n);
    end;
  end;
end.
