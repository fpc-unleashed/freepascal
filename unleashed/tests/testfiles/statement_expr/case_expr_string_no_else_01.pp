{ %FAIL %NORUN }
program case_expr_string_no_else_01;
{$mode unleashed}

// case-as-expression on a string subject has no enumerable range; an else
// branch is mandatory. used to fire IE 200611054, now a plain syntax error
var s: string;
begin
  s := 'x';
  var b := case s of
    'a': 'x';
  end;
end.
