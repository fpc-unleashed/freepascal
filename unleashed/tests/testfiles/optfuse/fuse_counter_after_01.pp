{ %OPT="-O4 -OoLOOPFUSE -vn" }
{ Loop fusion must leave both loop counters with the value a stand-alone
  for-loop would: the last taken value (hi) when the loop ran, and unchanged
  when it ran zero times. Checked for the same-counter and the two-counter
  (c2:=c1 binding) shapes, at a non-empty length and at the empty length. }
program fuse_counter_after_01;
{$mode objfpc}{$H+}

{ same counter i in both loops: after fusion i must be hi (n-1) if it ran }
procedure samectr(n: longint; out ival: longint);
var a,b: array of single; i: longint;
begin
  SetLength(a,n); SetLength(b,n);
  i:=-999;                      { sentinel visible only if loop never runs }
  for i:=0 to n-1 do a[i]:=i;
  for i:=0 to n-1 do b[i]:=a[i]*2.0;
  ival:=i;
end;

{ two counters i and j: j is rebound to i inside the fused loop, so after it j
  must be hi if the loop ran and the sentinel otherwise }
procedure twoctr(n: longint; out ival,jval: longint);
var a,b: array of single; i,j: longint;
begin
  SetLength(a,n); SetLength(b,n);
  i:=-999; j:=-777;
  for i:=0 to n-1 do a[i]:=i;
  for j:=0 to n-1 do b[j]:=a[j]*2.0;
  ival:=i; jval:=j;
end;

var iv,jv: longint;
begin
  { non-empty: counters end at hi = n-1 }
  samectr(5,iv);        if iv<>4 then Halt(1);
  twoctr(5,iv,jv);      if iv<>4 then Halt(2);
                        if jv<>4 then Halt(3);
  { length 1: hi = 0 }
  samectr(1,iv);        if iv<>0 then Halt(4);
  twoctr(1,iv,jv);      if (iv<>0) or (jv<>0) then Halt(5);
  { empty: loops never run, counters keep their sentinel }
  samectr(0,iv);        if iv<>-999 then Halt(6);
  twoctr(0,iv,jv);      if iv<>-999 then Halt(7);
                        if jv<>-777 then Halt(8);
end.
