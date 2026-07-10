{ %OPT=-O2 }
program int128_incdec_o2_01;

{ at -O2 the load-modify-store pass used to rewrite the lowered
  i := i + 1 back into inc(i), looping the compiler }

{$mode unleashed}

var
  a: Int128;
  u: UInt128;

begin
  a := 100000000000000000000;
  inc(a);
  if a <> 100000000000000000001 then halt(1);
  dec(a, 2);
  if a <> 99999999999999999999 then halt(2);
  a := succ(a);
  if a <> 100000000000000000000 then halt(3);
  a := pred(a);
  if a <> 99999999999999999999 then halt(4);

  u := high(UInt128) - 1;
  inc(u);
  if u <> high(UInt128) then halt(5);
  dec(u);
  if u <> high(UInt128) - 1 then halt(6);
end.
