{ %OPT="-O4 -OoVECTORIZE -Cfavx2" }
{ Under an AVX fputype the packed body uses the VEX v-forms (vmovups/vaddps/
  vmulps/vsubps); results must be bit-identical to scalar. }
program vect_avx_01;
{$mode objfpc}{$H+}
procedure work(n: longint);
var a,b,c: array of single; i: longint; d: single;
begin
  SetLength(a,n); SetLength(b,n); SetLength(c,n);
  for i:=0 to n-1 do begin b[i]:=i*0.5+1; c[i]:=i*0.25-2; end;
  for i:=0 to n-1 do a[i]:=b[i]*c[i];
  for i:=0 to n-1 do begin d:=b[i]*c[i]; if a[i]<>d then Halt(1); end;
end;
var k: longint;
begin
  for k:=0 to 15 do work(k); work(300);
end.
