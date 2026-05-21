{ %FAIL %NORUN }
program match_expr_empty_body_01;
{$mode unleashed}

// match-as-expression branch body must be an expression, not empty
var s: string;
begin
  s := 'x';
  var d: string := match s of
    'a': ;
    _: 'else';
  end;
end.
