program int128_control_01;

{ for-loop counter, case selector, inc/dec/succ/pred, abs/odd/sqr on 128 bit }

{$mode unleashed}

var
  a, c: Int128;
  n: Integer;

begin
  { for-loop with a 128 bit counter straddling the top of the range }
  c := 0;
  for a := high(Int128) - 2 to high(Int128) do
    c := c + 1;
  if c <> 3 then halt(1);

  n := 0;
  for a := 3 downto 1 do
    inc(n);
  if n <> 3 then halt(2);

  { case on a 128 bit selector }
  a := 100000000000000000000;
  case a of
    1:                     n := 10;
    100000000000000000000: n := 20;
  else
    n := 30;
  end;
  if n <> 20 then halt(3);

  { inc / dec / succ / pred }
  a := high(Int128) - 1;
  inc(a);
  if a <> high(Int128) then halt(4);
  dec(a, 2);
  if a <> high(Int128) - 2 then halt(5);
  a := 100000000000000000000;
  if succ(a) <> 100000000000000000001 then halt(6);
  if pred(a) <> 99999999999999999999 then halt(7);

  { abs / odd / sqr }
  a := -123456789012345678901234567890;
  if abs(a) <> 123456789012345678901234567890 then halt(8);
  if not odd(Int128(7)) then halt(9);
  if odd(Int128(8)) then halt(10);
  a := 10000000000000000000;
  if sqr(a) <> 100000000000000000000000000000000000000 then halt(11);
end.
