{ %FAIL %NORUN }
program case_expr_int_no_else_partial_01;
{$mode unleashed}

// case-as-expression on an ordinal subject that doesn't enumerate every
// value needs an else branch
var n: Integer;
begin
  n := 5;
  var s := case n of
    1: 'one';
    2: 'two';
  end;
end.
