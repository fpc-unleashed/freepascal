{ %OPT=-O2 }
program int128_cse_o2_01;

{ at -O2 cse makes temps for the repeated subexpressions below; the div
  helper call then carried the temp block in a parameter and the x86_64
  mul dispatch secondpassed it twice (IE 200108222) }

{$mode unleashed}

var
  b, a: Int128;
  u, v: UInt128;

begin
  { ParamCount keeps the values out of reach of constant folding }
  b := 100000000000000000000 + ParamCount;
  a := (b + b) div 3 * 3;
  if a <> 199999999999999999998 then halt(1);
  a := (b * 2 - b) div 3 * 3 + b mod 3;
  if a <> b then halt(2);
  b := -b;
  a := (b + b) div 3 * 3;
  if a <> -199999999999999999998 then halt(3);

  u := 200000000000000000000 + ParamCount;
  v := (u + u) div 3 * 3;
  if v <> 399999999999999999999 then halt(4);
  { wraps mod 2^128, the div/mod identity still holds }
  u := high(UInt128) - 55 + ParamCount;
  v := (u * 2 - u) div 3 * 3 + u mod 3;
  if v <> u then halt(5);
end.
