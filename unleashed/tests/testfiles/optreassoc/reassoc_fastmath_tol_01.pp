{ %OPT=-O4 }
{ Under fast-math the four-way split reassociates the additions, so for inputs
  that are NOT exactly representable the single-precision result differs from the
  strict serial order by rounding -- but only by a few ULP, and typically it is
  MORE accurate (the four shorter chains accumulate less error). This checks the
  split single-precision dot product stays within a small tolerance of a high-
  precision (extended, sequential) reference. }
program reassoc_fastmath_tol_01;
{$mode objfpc}{$H+}
function dot_fast(const a,b: array of single): single;
var i: longint; s: single;
begin s:=0; for i:=0 to high(a) do s:=s+a[i]*b[i]; dot_fast:=s; end;
function dot_ext(const a,b: array of single): extended;
var i: longint; s: extended; p: pointer;
begin s:=0; p:=@s; for i:=0 to high(a) do s:=s+extended(a[i])*extended(b[i]); dot_ext:=s; if p=nil then Halt(9); end;
var a,b: array of single; i,n: longint; got: single; ref, tol: extended;
begin
  for n:=1 to 300 do
    begin
      SetLength(a,n); SetLength(b,n);
      for i:=0 to n-1 do begin a[i]:=1.0/(i+1); b[i]:=1.0/(2*i+3); end;
      got:=dot_fast(a,b);
      ref:=dot_ext(a,b);
      tol:=(Abs(ref)+1.0)*1e-4;
      if Abs(extended(got)-ref)>tol then Halt(1);
    end;
end.
