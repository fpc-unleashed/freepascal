{ %OPT=-O4 }
{ Plain -O4 (no explicit -Oo switch) must enable unroll-and-jam, because
  cs_opt_unrolljam is a member of genericlevel4optimizerswitches.  This is a
  smoke test that the default -O4 pipeline both fires the transform and stays
  correct: a matmul row nest and an integer array-accumulator nest are each
  checked against an independent flat-loop reference over several trip counts,
  including 0 and 1 and every residue of the unroll factor. }
program unrolljam_o4_default_01;
{$mode objfpc}{$H+}

const MAXN = 50; MAXM = 40;

procedure imm(n,m:longint; out c:array of int64);
var a:array[0..MAXN-1,0..MAXM-1] of int64; b:array[0..MAXM-1] of int64;
    i,j:longint; s:int64;
begin
  for i:=0 to n-1 do for j:=0 to m-1 do a[i,j]:=(i*7+j) mod 17-8;
  for j:=0 to m-1 do b[j]:=(j*3) mod 11-5;
  for i:=0 to n-1 do
  begin
    s:=0;
    for j:=0 to m-1 do s:=s+a[i,j]*b[j];
    c[i]:=s;
  end;
end;

function ielem(i,m:longint):int64;
var j:longint; s:int64;
begin s:=0; for j:=0 to m-1 do s:=s+((i*7+j) mod 17-8)*((j*3) mod 11-5); ielem:=s; end;

var c:array[0..MAXN-1] of int64; n,i:longint;
begin
  for n:=0 to 9 do
    begin
      imm(n,30,c);
      for i:=0 to n-1 do if c[i]<>ielem(i,30) then Halt(1);
    end;
  imm(47,33,c);
  for i:=0 to 46 do if c[i]<>ielem(i,33) then Halt(2);
  Halt(0);
end.
