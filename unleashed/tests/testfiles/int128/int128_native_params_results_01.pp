program int128_native_params_results_01;

{ register-pair ABI: params travel in GPR pairs, results in RAX:RDX, and
  arguments spill to the stack when the registers run out }

{$mode unleashed}

function addpair(a, b: Int128): Int128;
begin
  result := a + b;
end;

function sum5(a, b, c, d, e: Int128): Int128;
begin
  result := a + b + c + d + e;
end;

function mixed(a: Int128; n: longint; b: Int128; m: int64): Int128;
begin
  result := a + b + n + m;
end;

function fac(n: longint): Int128;
begin
  if n <= 1 then
    result := 1
  else
    result := fac(n - 1) * n;
end;

function usum(a, b: UInt128): UInt128;
begin
  result := a + b;
end;

var
  a, b, r: Int128;
  u: UInt128;

begin
  a := 100000000000000000000;                       { needs the high half }
  b := 23456789012345678901;
  r := addpair(a, b);
  if r <> 123456789012345678901 then halt(1);

  r := sum5(a, a, a, a, a);
  if r <> 500000000000000000000 then halt(2);

  r := sum5(1, 2, 3, 4, high(Int128) - 10);
  if r <> high(Int128) then halt(3);

  r := mixed(a, 1000, -a, -1000);
  if r <> 0 then halt(4);

  r := fac(33);
  if r <> 8683317618811886495518194401280000000 then halt(5);

  u := usum(high(UInt128) - 5, 3);
  if u <> high(UInt128) - 2 then halt(6);

  { nested calls keep their pairs apart }
  r := addpair(addpair(a, b), addpair(-a, -b));
  if r <> 0 then halt(7);
end.
