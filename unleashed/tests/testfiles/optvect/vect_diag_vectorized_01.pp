{ %OPT="-O4 -OoVECTORIZE -Cfsse64 -vn" }
{ Vectorization diagnostic active (-vn) on a loop that DOES autovectorize.
  The -Oo VECTORIZE recognizer emits cg_n_loop_vectorized (06065) as a note at
  the for-loop position; a note must never break compilation and must not change
  codegen, so the packed result has to stay bit-exact vs the scalar recompute. }
program vect_diag_vectorized_01;
{$mode objfpc}{$H+}
procedure work(n: longint);
var a,b,c: array of single; i: longint; d: single;
begin
  SetLength(a,n); SetLength(b,n); SetLength(c,n);
  for i:=0 to n-1 do begin b[i]:=i*1.25+0.5; c[i]:=i*0.5-2; end;
  { this loop is recognized -> "Loop autovectorized (SSE, 4-wide packed single)" }
  for i:=0 to n-1 do a[i]:=b[i]+c[i];
  for i:=0 to n-1 do begin d:=b[i]+c[i]; if a[i]<>d then Halt(1); end;
end;
var k: longint;
begin
  for k:=0 to 10 do work(k);
  work(257);
end.
