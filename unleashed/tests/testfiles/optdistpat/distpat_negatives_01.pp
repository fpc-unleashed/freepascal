{ %OPT="-O4 -OoLOOPDISTPAT -vn" }
{ Shapes the pass must decline, each emitting a cg_n_loop_not_lowered (06068)
  note naming the reason; the transform is measure-only, so every loop must
  still compute the same result as the scalar code. Declines covered:
  downto, multi-statement body, non-counter (offset) index, managed element,
  self-modifying value (a[i]:=i), double:=single copy (element types differ),
  and non-zero float fill. }
program distpat_negatives_01;
{$mode objfpc}{$H+}

procedure work(n: longint);
var
  a,b: array of longint;
  s: array of single;
  d: array of double;
  ss: array of ansistring;
  i,c: longint;
begin
  SetLength(a,n); SetLength(b,n); SetLength(s,n); SetLength(d,n); SetLength(ss,n);

  { downto: declined, must fill correctly }
  for i:=n-1 downto 0 do a[i]:=7;
  for i:=0 to n-1 do if a[i]<>7 then Halt(1);

  { multi-statement body }
  c:=0;
  for i:=0 to n-1 do begin a[i]:=0; inc(c); end;
  if c<>n then Halt(2);
  for i:=0 to n-1 do if a[i]<>0 then Halt(3);

  { non-counter (offset) index: not a plain unit-stride fill }
  if n>=2 then
    begin
      for i:=0 to n-2 do a[i]:=b[i+1];
      for i:=0 to n-2 do if a[i]<>b[i+1] then Halt(4);
    end;

  { managed element type (ansistring) }
  for i:=0 to n-1 do ss[i]:='x';
  for i:=0 to n-1 do if ss[i]<>'x' then Halt(5);

  { value depends on the counter -> not a fill }
  for i:=0 to n-1 do a[i]:=i;
  for i:=0 to n-1 do if a[i]<>i then Halt(6);

  { element-type-changing copy: double[i] := single[i] }
  for i:=0 to n-1 do s[i]:=i*0.5;
  for i:=0 to n-1 do d[i]:=s[i];
  for i:=0 to n-1 do if d[i]<>s[i] then Halt(7);

  { non-zero float fill (declined; only zero float lowers) }
  for i:=0 to n-1 do s[i]:=3.25;
  for i:=0 to n-1 do if s[i]<>3.25 then Halt(8);
end;

var k: longint;
begin
  for k:=0 to 10 do work(k);
  work(129);
end.
