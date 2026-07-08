{ %OPT=-O4 }
{ Reduction reassociation (-O4 -OoREASSOC) with the loop COUNTER inside the
  accumulated expression and the accumulator of the SAME width as the counter.
  The pass splits  for i:=lo to hi do r:=r+expr(i)  into 4 partial accumulators
  and substitutes  i -> (i+delta)  into copies of expr that were already
  firstpassed as part of the original body.  Every ancestor of the substituted
  counter read (the muln of i*2 / i*3 / 2*i) carried a cached resultdef and
  tnf_pass1_done from the original, so without a full re-typecheck+firstpass of
  the copy the +delta was silently dropped for a power-of-two multiply (i*2
  stayed i*2 in the delta lanes: Sum2(4) returned 8 instead of 20) and a
  non-power-of-two multiply (i*3) died with internalerror 200306031 at compile
  time.  Integer sums are exact under any grouping, so each split loop must
  equal the closed form for every trip count 0..40 (covering all remainder
  lanes) and a larger size. }
program reassoc_counterexpr_01;
{$mode objfpc}{$H+}
function Sum2(n: Integer): Integer;   { r + i*2 : power-of-two multiply }
var i, r: Integer;
begin r:=0; for i:=1 to n do r:=r+i*2; Result:=r; end;
function Sum3(n: Integer): Integer;   { r + i*3 : non-power-of-two multiply }
var i, r: Integer;
begin r:=0; for i:=1 to n do r:=r+i*3; Result:=r; end;
function Sum2L(n: Integer): Integer;  { r + 2*i : counter on the right }
var i, r: Integer;
begin r:=0; for i:=1 to n do r:=r+2*i; Result:=r; end;
function SumOff(n: Integer): Integer; { r + (i+100) : counter under an add }
var i, r: Integer;
begin r:=0; for i:=1 to n do r:=r+(i+100); Result:=r; end;
var
  n: Integer;
begin
  for n:=0 to 40 do
    begin
      if Sum2(n) <> n*(n+1) then Halt(1);
      if Sum3(n) <> 3*(n*(n+1) div 2) then Halt(2);
      if Sum2L(n) <> n*(n+1) then Halt(3);
      if SumOff(n) <> n*100 + n*(n+1) div 2 then Halt(4);
    end;
  if Sum2(10000) <> 10000*10001 then Halt(5);
  if Sum3(10000) <> 3*(10000*10001 div 2) then Halt(6);
end.
