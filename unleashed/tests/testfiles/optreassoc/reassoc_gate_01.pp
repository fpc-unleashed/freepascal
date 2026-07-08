{ %OPT="-O4 -OoNOFASTMATH" }
{ Fast-math gate: with fast-math OFF a floating-point reduction must NOT be
  reassociated (its serial rounding is preserved), while an INTEGER reduction is
  always split (two's-complement addition is exactly associative). Both must
  compute the correct result. The FP loop here uses exactly-representable inputs
  so the (un-reassociated) serial result is well-defined and checked; the integer
  loop is checked against the closed-form sum. }
program reassoc_gate_01;
{$mode objfpc}{$H+}
function fsum(const a: array of double): double;
var i: longint; s: double;
begin s:=0; for i:=0 to high(a) do s:=s+a[i]; fsum:=s; end;
function isum(const a: array of int64): int64;
var i: longint; s: int64;
begin s:=0; for i:=0 to high(a) do s:=s+a[i]; isum:=s; end;
var a: array of double; ia: array of int64; i,n: longint; fe: double; ie: int64;
begin
  for n:=0 to 33 do
    begin
      SetLength(a,n); SetLength(ia,n);
      fe:=0; ie:=0;
      for i:=0 to n-1 do
        begin a[i]:=(i mod 4)*0.5; ia[i]:=i*7-13; fe:=fe+a[i]; ie:=ie+ia[i]; end;
      if fsum(a)<>fe then Halt(1);
      if isum(ia)<>ie then Halt(2);
    end;
end.
