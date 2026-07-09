{ %OPT="-O2 -OoFINALVALUE" }
{ -OoFINALVALUE on downto loops and zero-trip loops: for a downto loop the
  trip count is  from-to+1  guarded by  to<=from , so a downto loop with to>from
  runs zero times and must leave the accumulator unchanged. Both the increment
  and decrement (dec / s:=s-c) accumulator forms are covered, checked against a
  direct reference for trip counts 0..40. }
program fv_downto_zerotrip_01;
{$mode objfpc}{$H+}

function down_inc(n: longint): longint;
var i,s: longint;
begin
  s:=0;
  for i:=n downto 1 do inc(s,7);   { runs max(0,n) times }
  down_inc:=s;
end;

function down_sub(n: longint): longint;
var i,s: longint;
begin
  s:=500;
  for i:=n downto 1 do s:=s-4;
  down_sub:=s;
end;

{ explicit zero-trip: to>from always }
function down_zero(n: longint): longint;
var i,s: longint;
begin
  s:=99;
  for i:=1 downto n do inc(s,1);   { n>1 => zero trips; runs max(0,1-n+1) times }
  down_zero:=s;
end;

var
  n,iters: longint;
begin
  for n:=0 to 40 do
    begin
      if n<0 then iters:=0 else iters:=n;
      if down_inc(n) <> 7*iters then Halt(1);
      if down_sub(n) <> 500 - 4*iters then Halt(2);
      { for i:=1 downto n : runs max(0, 1-n+1) = max(0,2-n) times }
      if (2-n) > 0 then
        begin if down_zero(n) <> 99 + (2-n) then Halt(3); end
      else
        begin if down_zero(n) <> 99 then Halt(4); end;
    end;
  Halt(0);
end.
