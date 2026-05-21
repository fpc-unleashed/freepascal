{ %FAIL %NORUN }
program case_expr_empty_body_01;
{$mode unleashed}

// case-as-expression branch body must be an expression, not an empty
// statement. used to fire IE 200611054, now a plain "illegal expression"
var s: string;
begin
  s := 'x';
  var a: string := case s of
    'a': ;
  else
    'else';
  end;
end.
