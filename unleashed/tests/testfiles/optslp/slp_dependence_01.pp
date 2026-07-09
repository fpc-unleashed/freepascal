{ %OPT="-O4 -OoSLP -Cfsse64" }
{ Runtime-semantics guard: a group with an intra-pack dependence must NOT be
  packed. In  a[k]:=a[k-1]+c[k]  the source index (k-1) differs from the
  destination index (k), so the statements are NOT element-wise; the recognizer
  requires every array access in a statement to use the SAME index and therefore
  leaves this group scalar. If it were wrongly packed (loading the whole a-window
  before any store) the recurrence a[1]:=a[0]+c[1] would read the OLD a[0]
  instead of the just-written one, giving a different result. We check the exact
  scalar recurrence value. }
program slp_dependence_01;
{$mode objfpc}{$H+}
type TA = array of single;

{ writes a[1..4] from a[0..3] and c[1..4]; each depends on the previous store }
procedure prefix(a,c: TA);
begin
  a[1]:=a[0]+c[1];
  a[2]:=a[1]+c[2];
  a[3]:=a[2]+c[3];
  a[4]:=a[3]+c[4];
end;

var
  a,c: TA;
  i: integer;
  acc: single;
begin
  SetLength(a,5); SetLength(c,5);
  a[0]:=1.0;
  for i:=1 to 4 do c[i]:=i*2.0;

  prefix(a,c);

  { reference: strictly sequential prefix sum }
  acc:=a[0];
  for i:=1 to 4 do
    begin
      acc:=acc+c[i];
      if a[i]<>acc then Halt(i);
    end;
end.
