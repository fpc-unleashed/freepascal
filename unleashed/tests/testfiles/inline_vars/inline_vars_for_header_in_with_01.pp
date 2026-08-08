program inline_vars_for_header_in_with_01;
// for-header inline var inside a with body

{$mode unleashed}

var
  r: record
    a: integer;
  end;
  sum: integer;

begin
  r.a := 10;
  sum := 0;
  with r do for var i := 1 to 3 do sum := sum+i+a;
  if sum <> 36 then halt(1);
end.
