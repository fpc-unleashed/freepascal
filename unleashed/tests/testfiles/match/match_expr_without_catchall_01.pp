{ %FAIL %NORUN }
program match_expr_without_catchall_01;
{$mode unleashed}

// match-as-expression must have either an `else` branch or a `_` catch-all;
// without it the expression has no defined value for unhandled inputs
var s: string;
begin
  s := 'x';
  var d := match s of
    'a': '1';
    'b': '2';
  end;
end.
