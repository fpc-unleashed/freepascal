{ %OPT="-O4 -OoSLP -Cfsse64" }
{ Groups that are not a clean 4-wide run of one shape are left scalar and must
  still compute correctly: (a) non-adjacent indices (a gap in the offsets breaks
  the +1-per-lane requirement); (b) a mixed-operator group (+ then - then *).
  Both stay scalar; results are checked against a scalar recompute. }
program slp_nonadjacent_mixedop_01;
{$mode objfpc}{$H+}
type TA = array of single;

{ offsets 0,1,3,4 -- a gap at index 2, so no contiguous 4-window exists }
procedure gap(a,b,c: TA);
begin
  a[0]:=b[0]+c[0];
  a[1]:=b[1]+c[1];
  a[3]:=b[3]+c[3];
  a[4]:=b[4]+c[4];
end;

{ same 4 slots, but the operator differs per statement }
procedure mixed(a,b,c: TA);
begin
  a[0]:=b[0]+c[0];
  a[1]:=b[1]-c[1];
  a[2]:=b[2]*c[2];
  a[3]:=b[3]+c[3];
end;

var
  a,b,c: TA;
  i: integer;
begin
  SetLength(a,5); SetLength(b,5); SetLength(c,5);
  for i:=0 to 4 do begin b[i]:=i*0.5+1; c[i]:=i*0.25-2; a[i]:=-999; end;

  gap(a,b,c);
  if a[0]<>b[0]+c[0] then Halt(1);
  if a[1]<>b[1]+c[1] then Halt(2);
  if a[2]<>-999 then Halt(3);          { untouched }
  if a[3]<>b[3]+c[3] then Halt(4);
  if a[4]<>b[4]+c[4] then Halt(5);

  mixed(a,b,c);
  if a[0]<>b[0]+c[0] then Halt(6);
  if a[1]<>b[1]-c[1] then Halt(7);
  if a[2]<>b[2]*c[2] then Halt(8);
  if a[3]<>b[3]+c[3] then Halt(9);
end.
