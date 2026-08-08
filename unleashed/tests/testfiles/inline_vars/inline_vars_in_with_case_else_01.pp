program inline_vars_in_with_case_else_01;
// inline var in a case else list nested under with lands in the enclosing scope

{$mode unleashed}

var
  r: record
    a: integer;
  end;

begin
  r.a := 2;
  with r do case a of
    999: halt(1);
  else
    var b := a+7;
    if b <> 9 then halt(2);
  end;
end.
