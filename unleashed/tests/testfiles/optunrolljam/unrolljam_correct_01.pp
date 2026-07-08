{ %OPT=-O4 }
{ Unroll-and-jam (-O4 -OoUNROLLJAM): the outer loop of a perfect two-level
  counted nest is unrolled by factor 4 and the four duplicated inner-loop bodies
  are jammed into one inner loop, so a value the inner body loads once (b[j] in a
  matmul-shaped nest) is reused across the four unrolled outer rows and a per-row
  scalar accumulator is register-blocked.

  The jam does NOT reassociate: each of the four accumulators sums exactly one
  outer row in the original j order, so every produced value is bit-identical to
  the untransformed nest for ANY input (no fast-math needed).  This is checked two
  ways for both a scalar-accumulator matmul and an array-element accumulator:
    * _fast  (ascending outer) is the nest the pass jams;
    * _ref   (descending outer, downto) makes the pass decline (backward loop) and
      stays strictly serial -- and because every result element c[i] is computed
      independently of the others, iterating i backwards yields the identical
      array, so _fast must equal _ref elementwise;
    * an independent, differently-structured scalar reference recomputes each
      element from scratch, pinning the absolute values too.
  Covered outer trip counts include 0,1,2,3 (all below the factor -> pure
  remainder), 4 (one jammed group, empty remainder), 5..7 (group + every residue)
  and larger sizes hitting every residue of the main-loop bound. }
program unrolljam_correct_01;
{$mode objfpc}{$H+}

const MAXN = 260; MAXM = 70;

{ ---- scalar-accumulator matmul row: c[i] := sum_j a[i,j]*b[j] ---- }
procedure mm_fast(n,m:longint; out c:array of double);
var a:array[0..MAXN-1,0..MAXM-1] of double; b:array[0..MAXM-1] of double;
    i,j:longint; s:double;
begin
  for i:=0 to n-1 do begin for j:=0 to m-1 do a[i,j]:=((i*13+j*7) mod 17)-8.0; end;
  for j:=0 to m-1 do b[j]:=((j*5) mod 11)-5.0;
  for i:=0 to n-1 do
  begin
    s:=0;
    for j:=0 to m-1 do
      s:=s+a[i,j]*b[j];
    c[i]:=s;
  end;
end;

procedure mm_ref(n,m:longint; out c:array of double);
var a:array[0..MAXN-1,0..MAXM-1] of double; b:array[0..MAXM-1] of double;
    i,j:longint; s:double;
begin
  for i:=0 to n-1 do begin for j:=0 to m-1 do a[i,j]:=((i*13+j*7) mod 17)-8.0; end;
  for j:=0 to m-1 do b[j]:=((j*5) mod 11)-5.0;
  for i:=n-1 downto 0 do   { backward outer -> pass declines -> strictly serial }
  begin
    s:=0;
    for j:=0 to m-1 do
      s:=s+a[i,j]*b[j];
    c[i]:=s;
  end;
end;

{ ---- array-element accumulator: c[i] += a[i,j]*b[j] (no scalar) ---- }
procedure ac_fast(n,m:longint; out c:array of double);
var a:array[0..MAXN-1,0..MAXM-1] of double; b:array[0..MAXM-1] of double;
    i,j:longint;
begin
  for i:=0 to n-1 do begin c[i]:=0; for j:=0 to m-1 do a[i,j]:=((i*3+j*11) mod 13)-6.0; end;
  for j:=0 to m-1 do b[j]:=((j*7) mod 9)-4.0;
  for i:=0 to n-1 do
    for j:=0 to m-1 do
      c[i]:=c[i]+a[i,j]*b[j];
end;

procedure ac_ref(n,m:longint; out c:array of double);
var a:array[0..MAXN-1,0..MAXM-1] of double; b:array[0..MAXM-1] of double;
    i,j:longint;
begin
  for i:=0 to n-1 do begin c[i]:=0; for j:=0 to m-1 do a[i,j]:=((i*3+j*11) mod 13)-6.0; end;
  for j:=0 to m-1 do b[j]:=((j*7) mod 9)-4.0;
  for i:=n-1 downto 0 do
    for j:=0 to m-1 do
      c[i]:=c[i]+a[i,j]*b[j];
end;

{ independent absolute references (single flat loop each) }
function elem_mm(i,m:longint):double;
var j:longint; s:double;
begin
  s:=0;
  for j:=0 to m-1 do
    s:=s+(((i*13+j*7) mod 17)-8.0)*(((j*5) mod 11)-5.0);
  elem_mm:=s;
end;

function elem_ac(i,m:longint):double;
var j:longint; s:double;
begin
  s:=0;
  for j:=0 to m-1 do
    s:=s+(((i*3+j*11) mod 13)-6.0)*(((j*7) mod 9)-4.0);
  elem_ac:=s;
end;

var cf,cr:array[0..MAXN-1] of double; n,m,i:longint;

  procedure check(n,m:longint);
  var i:longint;
  begin
    mm_fast(n,m,cf); mm_ref(n,m,cr);
    for i:=0 to n-1 do
      begin
        if cf[i]<>cr[i] then Halt(1);
        if cf[i]<>elem_mm(i,m) then Halt(2);
      end;
    ac_fast(n,m,cf); ac_ref(n,m,cr);
    for i:=0 to n-1 do
      begin
        if cf[i]<>cr[i] then Halt(3);
        if cf[i]<>elem_ac(i,m) then Halt(4);   { same arithmetic, exact }
      end;
  end;

begin
  { every small outer trip count: 0..8 covers below-factor, factor and every
    residue past it }
  for n:=0 to 8 do check(n,25);
  { vary the inner length too (including 0 and 1) }
  for m:=0 to 5 do check(7,m);
  { larger sizes hitting every residue of the (hi-3) main-loop bound }
  for n:=200 to 205 do check(n,64);
  Halt(0);
end.
