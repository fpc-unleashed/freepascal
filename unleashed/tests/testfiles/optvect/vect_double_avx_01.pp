{ %OPT="-O4 -OoVECTORIZE -OoFASTMATH -Cfavx2" }
{ Under an AVX2 fputype the packed double body uses the VEX v-forms (vmovupd/
  vaddpd/vsubpd/vmulpd; vxorpd/vmovsd/vunpckhpd/vaddsd for the reduction), still
  128-bit (2-wide); results must be bit-identical to the scalar path. Exercises
  the element-wise store shapes and both reduction shapes (an FMA-capable target
  additionally contracts s+a[i]*b[i] into an fma() node, whose double form the
  recognizer accepts and widens to vmulpd+vaddpd under fast-math). For
  exactly-representable inputs there is no rounding, so the packed reduction
  equals the strict sequential (downto) reference. }
program vect_double_avx_01;
{$mode objfpc}{$H+}
function qb(x: double): qword; var q: qword absolute x; begin qb:=q; end;
procedure work(n: longint; base: double);
var a,b,c: array of double; i: longint; d,s,ref: double;
begin
  SetLength(a,n); SetLength(b,n); SetLength(c,n);
  for i:=0 to n-1 do begin b[i]:=(i mod 8)*0.125-0.5; c[i]:=(i mod 4)*0.25+0.25; end;

  { element-wise store shapes, bit-exact }
  for i:=0 to n-1 do a[i]:=b[i]*c[i];
  for i:=0 to n-1 do begin d:=b[i]*c[i]; if qb(a[i])<>qb(d) then Halt(1); end;
  for i:=0 to n-1 do a[i]:=b[i]-c[i];
  for i:=0 to n-1 do begin d:=b[i]-c[i]; if qb(a[i])<>qb(d) then Halt(2); end;

  { sum reduction vs descending sequential oracle }
  s:=base; for i:=0 to n-1 do s:=s+b[i];
  ref:=base; for i:=n-1 downto 0 do ref:=ref+b[i];
  if s<>ref then Halt(3);

  { dot product reduction }
  s:=base; for i:=0 to n-1 do s:=s+b[i]*c[i];
  ref:=base; for i:=n-1 downto 0 do ref:=ref+b[i]*c[i];
  if s<>ref then Halt(4);
end;
var k: longint;
begin
  for k:=0 to 20 do begin work(k,0.0); work(k,6.25); end;
  work(2049,-8.0);
end.
