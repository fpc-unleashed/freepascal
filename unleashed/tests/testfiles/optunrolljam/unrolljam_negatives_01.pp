{ %OPT=-O4 }
{ Unroll-and-jam decline paths (-O4 -OoUNROLLJAM).  Each of these two-level nests
  must NOT be transformed -- unrolling the outer loop and jamming the inner bodies
  would be an illegal reorder -- and must still compute the correct result.  A
  differently-structured independent reference pins the value in every case:
    * carried : loop-carried outer dependence  c[i]:=c[i-1]+rowsum  (a later outer
      iteration reads an element the previous one wrote -> declined via the
      "outer counter used outside a bare subscript" / c[i-1] offset rule);
    * withbreak : a break in the inner body (control must not enter a jammed body
      mid-stream -> declined);
    * offset : an inner read a[i+1,j] indexed by i+1 (offset outer index -> the
      four unrolled copies would not touch disjoint slices -> declined);
    * ataken : an address-taken scalar accumulator (cannot be renamed per copy ->
      declined);
    * reduction : a scalar that accumulates ACROSS the outer loop (s live outside
      the nest -> renaming per copy would split the reduction -> declined).
  The suite asserts each result equals its independent reference; the pass leaving
  them untouched is what makes -vn print "Loop nest not unroll-and-jammed" for
  every one of them (not machine-checked here, only the correctness is). }
program unrolljam_negatives_01;
{$mode objfpc}{$H+}

const MAXN = 40; MAXM = 30;

{ loop-carried outer dependence: c[i] depends on c[i-1] }
procedure carried(n,m:longint; out c:array of int64);
var i,j:longint; s:int64;
begin
  c[0]:=1;
  for i:=1 to n-1 do
  begin
    s:=0;
    for j:=0 to m-1 do s:=s+((i+j) mod 5);
    c[i]:=c[i-1]+s;
  end;
end;

{ break in the inner body }
procedure withbreak(n,m:longint; out c:array of int64);
var a:array[0..MAXN-1,0..MAXM-1] of int64; i,j:longint; s:int64;
begin
  for i:=0 to n-1 do for j:=0 to m-1 do a[i,j]:=(i*j) mod 23;
  for i:=0 to n-1 do
  begin
    s:=0;
    for j:=0 to m-1 do
      begin
        if a[i,j]>17 then break;
        s:=s+a[i,j];
      end;
    c[i]:=s;
  end;
end;

{ inner reads a[i+1,j] : offset outer index }
procedure offset(n,m:longint; out c:array of int64);
var a:array[0..MAXN,0..MAXM-1] of int64; i,j:longint; s:int64;
begin
  for i:=0 to n do for j:=0 to m-1 do a[i,j]:=(i*3+j) mod 13;
  for i:=0 to n-1 do
  begin
    s:=0;
    for j:=0 to m-1 do s:=s+a[i+1,j];
    c[i]:=s;
  end;
end;

{ address-taken accumulator }
procedure ataken(n,m:longint; out c:array of int64);
var a:array[0..MAXN-1,0..MAXM-1] of int64; i,j:longint; s:int64; p:pointer;
begin
  for i:=0 to n-1 do for j:=0 to m-1 do a[i,j]:=(i+2*j) mod 29;
  p:=@s;
  for i:=0 to n-1 do
  begin
    s:=0; p:=@s;
    for j:=0 to m-1 do s:=s+a[i,j];
    c[i]:=s;
  end;
  if p=nil then Halt(99);
end;

{ scalar reduction across the outer loop (s live outside the nest) }
function reduction(n,m:longint):int64;
var a:array[0..MAXN-1,0..MAXM-1] of int64; i,j:longint; s:int64;
begin
  for i:=0 to n-1 do for j:=0 to m-1 do a[i,j]:=(i*5+j*2) mod 31;
  s:=0;
  for i:=0 to n-1 do
    for j:=0 to m-1 do
      s:=s+a[i,j];
  reduction:=s;
end;

{ independent references }
function r_carried(n,m,i:longint):int64;
var k,j:longint; s,acc:int64;
begin
  acc:=1;
  for k:=1 to i do begin s:=0; for j:=0 to m-1 do s:=s+((k+j) mod 5); acc:=acc+s; end;
  r_carried:=acc;
end;
function r_break(n,m,i:longint):int64;
var j:longint; s,v:int64;
begin
  s:=0;
  for j:=0 to m-1 do begin v:=(i*j) mod 23; if v>17 then break; s:=s+v; end;
  r_break:=s;
end;
function r_offset(n,m,i:longint):int64;
var j:longint; s:int64;
begin s:=0; for j:=0 to m-1 do s:=s+(((i+1)*3+j) mod 13); r_offset:=s; end;
function r_ataken(n,m,i:longint):int64;
var j:longint; s:int64;
begin s:=0; for j:=0 to m-1 do s:=s+((i+2*j) mod 29); r_ataken:=s; end;
function r_reduction(n,m:longint):int64;
var i,j:longint; s:int64;
begin s:=0; for i:=0 to n-1 do for j:=0 to m-1 do s:=s+((i*5+j*2) mod 31); r_reduction:=s; end;

var c:array[0..MAXN-1] of int64; n,m,i:longint;
begin
  for n:=0 to 10 do
    for m:=1 to 6 do
      begin
        if n>=1 then begin carried(n,m,c); for i:=1 to n-1 do if c[i]<>r_carried(n,m,i) then Halt(1); end;
        withbreak(n,m,c); for i:=0 to n-1 do if c[i]<>r_break(n,m,i) then Halt(2);
        offset(n,m,c); for i:=0 to n-1 do if c[i]<>r_offset(n,m,i) then Halt(3);
        ataken(n,m,c); for i:=0 to n-1 do if c[i]<>r_ataken(n,m,i) then Halt(4);
        if reduction(n,m)<>r_reduction(n,m) then Halt(5);
      end;
  Halt(0);
end.
