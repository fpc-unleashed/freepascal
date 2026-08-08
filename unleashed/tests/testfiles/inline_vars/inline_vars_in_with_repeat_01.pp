program inline_vars_in_with_repeat_01;
// inline var in a repeat body nested under with lands in the enclosing scope

{$mode unleashed}

var
  r: record
    a: integer;
  end;

begin
  r.a := 3;
  with r do repeat
    var b := a*2;
    if b <> 6 then halt(1);
  until true;
end.
