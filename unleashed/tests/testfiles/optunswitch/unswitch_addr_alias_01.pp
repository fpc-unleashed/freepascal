{ %OPT="-O4" }
{ The condition variable's address is taken and it is modified through the
  pointer inside the loop, so it must not be treated as invariant and the loop
  must NOT be unswitched. Here "flag" flips via p^ each iteration; a wrong
  unswitch that froze the condition would give the wrong accumulation. }
program unswitch_addr_alias_01;
{$mode objfpc}
{$OPTIMIZATION NOAUTOINLINE}

function work(n: longint): longint;
var
  i, acc: longint;
  flag: boolean;
  p: ^boolean;
begin
  flag := true;
  p := @flag;
  acc := 0;
  for i := 1 to n do
    begin
      if flag then
        acc := acc + i          { flag true on i=1,3,5 -> +9 }
      else
        acc := acc - i;         { flag false on i=2,4,6 -> -12 }
      p^ := not p^;             { toggles flag through an alias }
    end;
  work := acc;                  { 9 - 12 = -3 }
end;

begin
  if work(6) <> -3 then Halt(1);
end.
