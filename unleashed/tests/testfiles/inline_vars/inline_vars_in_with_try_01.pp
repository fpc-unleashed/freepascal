program inline_vars_in_with_try_01;
// inline var in a try body nested under with lands in the enclosing scope

{$mode unleashed}

var
  r: record
    a: integer;
  end;

begin
  r.a := 5;
  with r do try
    var b := a+1;
    if b <> 6 then halt(1);
  except
    halt(2);
  end;
  with r do try
    var c := 1;
    c := c+a;
    if c <> 6 then halt(3);
  finally
  end;
end.
