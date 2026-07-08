{ %OPT="-O4 -OoVECTORIZE -Cfsse64 -vn" }
{ A scalar operand that is NOT a proven loop-invariant simple local/param must
  fall back to scalar code: a global variable and an address-taken local are
  both rejected by the recognizer (they emit a cg_n_loop_not_vectorized note
  naming the reason). The diagnostic is measure-only, so the scalar fallback
  must still compute the identical result. A plain single local IS invariant
  and vectorizes -- also verified bit-exact. }
program vect_scalar_noninvariant_01;
{$mode objfpc}{$H+}
var g: single;
procedure work(n: longint);
var a,b: array of single; i: longint; loc,inv: single; p: ^single; d: single;
begin
  SetLength(a,n); SetLength(b,n);
  for i:=0 to n-1 do b[i]:=i*1.25-4;

  { global scalar g -> NOT vectorized, but result must be correct }
  for i:=0 to n-1 do a[i]:=b[i]+g;
  for i:=0 to n-1 do begin d:=b[i]+g; if a[i]<>d then Halt(1); end;

  { address-taken local loc -> NOT vectorized, result must be correct }
  loc:=2.0; p:=@loc; p^:=p^+0.5;
  for i:=0 to n-1 do a[i]:=b[i]*loc;
  for i:=0 to n-1 do begin d:=b[i]*loc; if a[i]<>d then Halt(2); end;

  { plain single local inv -> IS invariant, vectorizes, must be correct }
  inv:=3.0;
  for i:=0 to n-1 do a[i]:=inv-b[i];
  for i:=0 to n-1 do begin d:=inv-b[i]; if a[i]<>d then Halt(3); end;
end;
var k: longint;
begin
  g:=1.5;
  for k:=0 to 12 do work(k);
  work(200);
end.
