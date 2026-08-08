program inline_vars_const_in_with_try_01;
// inline const in a try body nested under with lands in the enclosing scope

{$mode unleashed}

var
  r: record
    a: integer;
  end;

begin
  r.a := 1;
  with r do try
    const k = 7;
    if a+k <> 8 then halt(1);
  except
    halt(2);
  end;
end.
