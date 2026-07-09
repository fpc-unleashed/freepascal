{ %OPT="-O4 -Cfsse64" }
{ Control: the very same hand-unrolled kernels as slp_arr_arr_01, compiled with
  -OoSLP OFF (only -O4). Nothing is packed; the code stays scalar and must
  produce the identical, correct results. Pairs with the SLP-on tests to show
  the transform is opt-in and semantics-preserving either way. }
program slp_disabled_01;
{$mode objfpc}{$H+}
type TA = array of single;

procedure add8(a,b,c: TA);
begin
  a[0]:=b[0]+c[0]; a[1]:=b[1]+c[1]; a[2]:=b[2]+c[2]; a[3]:=b[3]+c[3];
  a[4]:=b[4]+c[4]; a[5]:=b[5]+c[5]; a[6]:=b[6]+c[6]; a[7]:=b[7]+c[7];
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
end.
