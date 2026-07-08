{ %OPT=-O4 }
{ Reduction reassociation (-O4 -OoREASSOC): a  for i:=lo to hi do acc:=acc+expr
  sum / dot-product loop is split into four independent partial accumulators
  combined after the loop. For exactly-representable inputs (small binary
  fractions whose exact total is < 2^53) every grouping yields the identical
  double, and integer sums are exact under any grouping, so the split result must
  equal a strictly-sequential reference for every trip count 0..40 and a large
  size. The reference accumulators are address-taken, which makes the pass
  decline them (they stay a plain serial sum) -- so this also proves the split
  loop reproduces the serial reduction. }
program reassoc_correct_01;
{$mode objfpc}{$H+}
function dot_fast(const a,b: array of double): double;
var i: longint; s: double;
begin s:=0; for i:=0 to high(a) do s:=s+a[i]*b[i]; dot_fast:=s; end;
function sum_fast(const a: array of double): double;
var i: longint; s: double;
begin s:=0; for i:=0 to high(a) do s:=s+a[i]; sum_fast:=s; end;
function isum_fast(const a: array of longint): longint;
var i: longint; s: longint;
begin s:=0; for i:=0 to high(a) do s:=s+a[i]; isum_fast:=s; end;
{ address-taken accumulator -> reassoc declines -> strictly sequential reference }
function dot_ref(const a,b: array of double): double;
var i: longint; s: double; p: pointer;
begin s:=0; p:=@s; for i:=0 to high(a) do s:=s+a[i]*b[i]; dot_ref:=s; if p=nil then Halt(9); end;
function sum_ref(const a: array of double): double;
var i: longint; s: double; p: pointer;
begin s:=0; p:=@s; for i:=0 to high(a) do s:=s+a[i]; sum_ref:=s; if p=nil then Halt(9); end;
function isum_ref(const a: array of longint): longint;
var i: longint; s: longint; p: pointer;
begin s:=0; p:=@s; for i:=0 to high(a) do s:=s+a[i]; isum_ref:=s; if p=nil then Halt(9); end;
var a,b: array of double; ia: array of longint; i,n: longint;
begin
  for n:=0 to 40 do
    begin
      SetLength(a,n); SetLength(b,n); SetLength(ia,n);
      for i:=0 to n-1 do
        begin a[i]:=(i mod 8)*0.25; b[i]:=(i mod 4)-1.0; ia[i]:=i*3-7; end;
      if dot_fast(a,b)<>dot_ref(a,b) then Halt(1);
      if sum_fast(a)<>sum_ref(a) then Halt(2);
      if isum_fast(ia)<>isum_ref(ia) then Halt(3);
    end;
  { larger sizes covering every  hi-3  residue }
  for n:=997 to 1000 do
    begin
      SetLength(a,n); SetLength(b,n); SetLength(ia,n);
      for i:=0 to n-1 do
        begin a[i]:=(i mod 16)*0.125; b[i]:=(i mod 8)*0.5-2.0; ia[i]:=(i mod 101)-50; end;
      if dot_fast(a,b)<>dot_ref(a,b) then Halt(4);
      if sum_fast(a)<>sum_ref(a) then Halt(5);
      if isum_fast(ia)<>isum_ref(ia) then Halt(6);
    end;
end.
