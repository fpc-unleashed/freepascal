{ %FAIL }
program inline_vars_fail_control_body_for_in_tuple_01;
// inline var cannot be the only statement of a destructuring for-in body

{$mode unleashed}

type
  TPair = record
    k: integer;
    v: integer;
  end;

var
  items: array of TPair;

begin
  setlength(items, 1);
  items[0].k := 1;
  items[0].v := 2;
  for var (k, v) in items do var b := 2;
end.
