{ %OPT="-O2 -OoFINALVALUE" }
{ -OoFINALVALUE with a loop-INVARIANT (not constant) step: the increment may be
  any side-effect-free integer expression that references neither the counter
  nor the accumulator (here c*2, and a plain runtime variable). The closed form
  reads that invariant once. Checked against a direct reference. }
program fv_invariant_c_01;
{$mode objfpc}{$H+}

function acc_expr(n,c: longint): longint;
var i,s: longint;
begin
  s:=3;
  for i:=1 to n do inc(s, c*2 + 1);
  acc_expr:=s;
end;

function acc_var(n,step: longint): longint;
var i,s: longint;
begin
  s:=0;
  for i:=1 to n do s:=s+step;
  acc_var:=s;
end;

var
  n,c: longint;
begin
  for n:=0 to 30 do
    for c:=-4 to 4 do
      begin
        if acc_expr(n,c) <> 3 + n*(c*2+1) then Halt(1);
        if acc_var(n,c) <> n*c then Halt(2);
      end;
  Halt(0);
end.
