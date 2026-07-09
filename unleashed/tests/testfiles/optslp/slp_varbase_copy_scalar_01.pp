{ %OPT="-O4 -OoSLP -Cfsse64" }
{ SLP with a variable base + constant offset index (a[i+0..i+3]), plus the copy
  shape a[k]:=b[k] and the scalar-broadcast shapes a[k]:=b[k]*s and s-b[k].
  All are element-wise (every access in a statement uses the same index), so the
  pack is alias-safe. Verified bit-exact against a scalar recompute. }
program slp_varbase_copy_scalar_01;
{$mode objfpc}{$H+}
type TA = array of single;

{ variable base i, offsets 0..3 }
procedure addbase(a,b,c: TA; i: longint);
begin
  a[i]  :=b[i]  +c[i];
  a[i+1]:=b[i+1]+c[i+1];
  a[i+2]:=b[i+2]+c[i+2];
  a[i+3]:=b[i+3]+c[i+3];
end;

procedure copy4(a,b: TA);
begin
  a[0]:=b[0]; a[1]:=b[1]; a[2]:=b[2]; a[3]:=b[3];
end;

procedure scale4(a,b: TA; s: single);
begin
  a[0]:=b[0]*s; a[1]:=b[1]*s; a[2]:=b[2]*s; a[3]:=b[3]*s;
end;

{ non-commutative scalar-left:  s - b[k] }
procedure rsub4(a,b: TA; s: single);
begin
  a[0]:=s-b[0]; a[1]:=s-b[1]; a[2]:=s-b[2]; a[3]:=s-b[3];
end;

var
  a,b,c: TA;
  i: integer;
  d,s: single;
begin
  SetLength(a,8); SetLength(b,8); SetLength(c,8);
  for i:=0 to 7 do begin b[i]:=i*0.5+1; c[i]:=i*0.25-2; end;

  addbase(a,b,c,4);   { writes a[4..7] }
  for i:=4 to 7 do begin d:=b[i]+c[i]; if a[i]<>d then Halt(1); end;

  copy4(a,b);
  for i:=0 to 3 do if a[i]<>b[i] then Halt(2);

  s:=3.5;
  scale4(a,b,s);
  for i:=0 to 3 do begin d:=b[i]*s; if a[i]<>d then Halt(3); end;

  rsub4(a,b,s);
  for i:=0 to 3 do begin d:=s-b[i]; if a[i]<>d then Halt(4); end;
end.
