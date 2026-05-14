program if_expr_nested_01;

{$mode unleashed}

begin
  for var i := -2 to 2 do
  begin
    var s := if i < 0 then 'neg' else if i = 0 then 'zero' else 'pos';
    case i of
      -2, -1: if s <> 'neg'  then halt(1);
       0:    if s <> 'zero' then halt(2);
       1, 2: if s <> 'pos'  then halt(3);
    end;
  end;
end.
