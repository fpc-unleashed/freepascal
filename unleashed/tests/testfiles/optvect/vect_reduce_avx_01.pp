{ %OPT="-O4 -OoVECTORIZE -OoFASTMATH -Cfavx2" }
{ Under an AVX2 fputype the packed reduction uses the VEX v-forms
  (vmovups/vaddps/vmulps/vshufps/vaddss/vmovss).  On an FMA-capable target
  fast-math contracts  s + a[i]*b[i]  into an fma() node before the vectorizer
  runs; the recognizer accepts that FMA-contracted dot-product shape too and
  widens it to packed vmulps+vaddps (the contraction's rounding license already
  applies under fast-math).  For exactly-representable inputs there is no
  rounding, so the packed result equals the strict sequential (downto)
  reference. }
program vect_reduce_avx_01;
{$mode objfpc}{$H+}
procedure work(n: longint; base: single);
var a,b: array of single; i: longint; s,ref: single;
begin
  SetLength(a,n); SetLength(b,n);
  for i:=0 to n-1 do begin a[i]:=(i mod 8)*0.125-0.5; b[i]:=(i mod 4)*0.25+0.25; end;
  s:=base; for i:=0 to n-1 do s:=s+a[i];
  ref:=base; for i:=n-1 downto 0 do ref:=ref+a[i];
  if s<>ref then Halt(1);
  s:=base; for i:=0 to n-1 do s:=s+a[i]*b[i];
  ref:=base; for i:=n-1 downto 0 do ref:=ref+a[i]*b[i];
  if s<>ref then Halt(2);
end;
var k: longint;
begin
  for k:=0 to 20 do begin work(k,0.0); work(k,6.25); end;
  work(2049,-8.0);
end.
