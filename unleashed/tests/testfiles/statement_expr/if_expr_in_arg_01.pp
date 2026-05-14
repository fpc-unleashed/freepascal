program if_expr_in_arg_01;

{$mode unleashed}

uses SysUtils;

begin
  var n := 7;
  var s := Format('count is %d (%s)', [n, if n mod 2 = 0 then 'even' else 'odd']);
  if s <> 'count is 7 (odd)' then halt(1);

  n := 4;
  s := Format('count is %d (%s)', [n, if n mod 2 = 0 then 'even' else 'odd']);
  if s <> 'count is 4 (even)' then halt(2);
end.
