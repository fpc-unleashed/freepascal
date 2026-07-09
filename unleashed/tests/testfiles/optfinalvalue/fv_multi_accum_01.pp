{ %OPT="-O2 -OoFINALVALUE" }
{ -OoFINALVALUE multi-statement loop bodies: a body that is several statements,
  each an INDEPENDENT accumulator update of a DISTINCT plain local (integer or
  pointer), matches -- one closed form per accumulator under the shared trip-
  count guard. The accumulators evolve independently (no increment references
  another), so statement order is irrelevant. Covered: two integer accumulators
  with mixed inc/dec/assign forms and invariant steps, a mixed integer+pointer
  body, and downto/zero-trip. All checked bit-exact against a direct reference.
  A body updating the SAME accumulator twice must NOT match (double-counting)
  and is exercised in fv_no_transform for the kept-loop case. }
program fv_multi_accum_01;
{$mode objfpc}{$H+}

type
  PLongint = ^Longint;

const
  ES = SizeOf(Longint);

{ two independent integer accumulators, different forms and steps }
function two_int(n, a, b: longint): longint;
var i, s, t: longint;
begin
  s:=100; t:=-7;
  for i:=1 to n do
    begin
      inc(s, a);
      t:=t + b;
    end;
  two_int:=s*100000 + t;
end;

{ three accumulators, inc + dec + assign-subtract, downto }
function three(n, a, b, c: longint): longint;
var i, s, t, u: longint;
begin
  s:=0; t:=1000; u:=50;
  for i:=n downto 1 do
    begin
      inc(s, a);
      dec(t, b);
      u:=u - c;
    end;
  three:=s*1000000 + t*1000 + u;
end;

{ mixed integer accumulator + pointer stride in one body }
function int_and_ptr(base: PLongint; n, a, stride: longint): longint;
var i, s: longint; p: PLongint;
begin
  s:=3; p:=base;
  for i:=1 to n do
    begin
      inc(s, a);
      inc(p, stride);
    end;
  int_and_ptr:=s*1000 + (PtrInt(p)-PtrInt(base));
end;

var
  buf: array[0..2048] of longint;
  base: PLongint;
  n, a, b: longint;
begin
  base:=@buf[0];
  for n:=0 to 30 do
    for a:=-3 to 3 do
      begin
        b:=a*2 + 1;
        if two_int(n, a, b) <> (100 + a*n)*100000 + (-7 + b*n) then Halt(1);
        { downto runs max(0,n) times; n>=0 => n }
        if three(n, a, b, a) <> (a*n)*1000000 + (1000 - b*n)*1000 + (50 - a*n) then Halt(2);
        if int_and_ptr(base, n, a, 2) <> (3 + a*n)*1000 + (n*2*ES) then Halt(3);
      end;
  Halt(0);
end.
