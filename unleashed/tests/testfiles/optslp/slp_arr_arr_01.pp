{ %OPT="-O4 -OoSLP -Cfsse64" }
{ SLP (superword-level parallelism): a run of adjacent, isomorphic scalar
  single-precision assignments over consecutive constant array slots -- hand-
  unrolled straight-line code with no surrounding loop -- is packed into 128-bit
  SSE ops (movups+addps/subps/mulps). An 8-slot group packs as two 4-wide ops;
  the +, - and * shapes are all exercised. The arrays are value-parameter
  dynamic arrays of single (simple non-aliased, so the recognizer accepts them).
  Verified bit-exact against a scalar recompute. }
program slp_arr_arr_01;
{$mode objfpc}{$H+}
type TA = array of single;

procedure add8(a,b,c: TA);
begin
  a[0]:=b[0]+c[0]; a[1]:=b[1]+c[1]; a[2]:=b[2]+c[2]; a[3]:=b[3]+c[3];
  a[4]:=b[4]+c[4]; a[5]:=b[5]+c[5]; a[6]:=b[6]+c[6]; a[7]:=b[7]+c[7];
end;

procedure sub4(a,b,c: TA);
begin
  a[0]:=b[0]-c[0]; a[1]:=b[1]-c[1]; a[2]:=b[2]-c[2]; a[3]:=b[3]-c[3];
end;

procedure mul4(a,b,c: TA);
begin
  a[0]:=b[0]*c[0]; a[1]:=b[1]*c[1]; a[2]:=b[2]*c[2]; a[3]:=b[3]*c[3];
end;

var
  a,b,c: TA;
  i: integer;
  d: single;
begin
  SetLength(a,8); SetLength(b,8); SetLength(c,8);
  for i:=0 to 7 do begin b[i]:=i*0.5+1; c[i]:=i*0.25-2; end;

  add8(a,b,c);
  for i:=0 to 7 do begin d:=b[i]+c[i]; if a[i]<>d then Halt(1); end;

  sub4(a,b,c);
  for i:=0 to 3 do begin d:=b[i]-c[i]; if a[i]<>d then Halt(2); end;

  mul4(a,b,c);
  for i:=0 to 3 do begin d:=b[i]*c[i]; if a[i]<>d then Halt(3); end;
end.
