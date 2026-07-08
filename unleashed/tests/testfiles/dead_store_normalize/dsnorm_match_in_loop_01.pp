{ %OPT="-O3 -Oodeadstore" }
{ Regression: same normalize hoist bug as dsnorm_ifexpr_in_loop_01, but for a
  match-expression used as the initializer of an inline var inside a for loop.
  Each iteration must re-evaluate the match against the current counter. }
program dsnorm_match_in_loop_01;
{$mode unleashed}
var
  n: longint;
  acc: string;
begin
  for n := 1 to 5 do
  begin
    var s := match n of
      1: 'one';
      2: 'two';
      _: 'other';
    end;
    case n of
      1: if s <> 'one'   then Halt(1);
      2: if s <> 'two'   then Halt(2);
    else
      if s <> 'other' then Halt(3);
    end;
    acc := acc + s + '/';
  end;
  if acc <> 'one/two/other/other/other/' then Halt(4);
end.
