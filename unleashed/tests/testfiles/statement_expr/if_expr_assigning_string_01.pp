program if_expr_assigning_string_01;

{$mode unleashed}

begin
  for var n := 0 to 5 do
  begin
    var label_ := if n = 0 then 'zero'
                  else if n mod 2 = 0 then 'even'
                  else 'odd';
    case n of
      0:    if label_ <> 'zero' then halt(1);
      2, 4: if label_ <> 'even' then halt(2);
      1, 3, 5: if label_ <> 'odd'  then halt(3);
    end;
  end;
end.
