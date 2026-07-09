{ %OPT="-O4 -OoVECTORIZE -Cfsse64 -vn" }
{ Vectorization diagnostic active (-vn) on a mix of loops that do NOT
  autovectorize (mixed single/double precision, two-statement body, non-counter
  index) plus ones that do (single and double element-wise). Each falls back to
  correct code and emits a cg_n_loop_not_vectorized (06066) note naming the
  reason; the diagnostic is measure-only, so every loop must still compute the
  same result as before. }
program vect_diag_reasons_01;
{$mode objfpc}{$H+}
procedure work(n: longint);
var
  a,b,c: array of single;
  da,db,dc: array of double;
  i: longint; ds: single; dd: double;
begin
  SetLength(a,n); SetLength(b,n); SetLength(c,n);
  SetLength(da,n); SetLength(db,n); SetLength(dc,n);
  for i:=0 to n-1 do begin b[i]:=i*1.5-1; c[i]:=i*0.25+3; end;
  for i:=0 to n-1 do begin db[i]:=i*2.0-1; dc[i]:=i*0.5+7; end;

  { vectorized: single a[i]:=b[i]+c[i] }
  for i:=0 to n-1 do a[i]:=b[i]+c[i];
  for i:=0 to n-1 do begin ds:=b[i]+c[i]; if a[i]<>ds then Halt(1); end;

  { not vectorized: mixed single/double precision (single b promoted to double) }
  for i:=0 to n-1 do da[i]:=b[i]+dc[i];
  for i:=0 to n-1 do begin dd:=b[i]+dc[i]; if da[i]<>dd then Halt(2); end;

  { not vectorized: two statements in the loop body }
  for i:=0 to n-1 do begin a[i]:=b[i]-c[i]; c[i]:=c[i]+1; end;
  for i:=n-1 downto 0 do begin dc[i]:=c[i]-1; if a[i]<>b[i]-dc[i] then Halt(3); end;

  { not vectorized: non-counter (offset) index }
  if n>=2 then
    begin
      for i:=0 to n-2 do a[i]:=b[i+1]+c[i];
      for i:=0 to n-2 do begin ds:=b[i+1]+c[i]; if a[i]<>ds then Halt(4); end;
    end;
end;
var k: longint;
begin
  for k:=0 to 10 do work(k);
  work(129);
end.
