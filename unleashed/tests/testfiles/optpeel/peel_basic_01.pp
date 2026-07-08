{ %OPT="-O4 -OoLOOPPEEL" }
{ Full loop peeling of small constant-trip counted loops: ascending and
  descending, several trip counts, storing into static and open arrays. Each
  peeled loop must compute exactly the same values a scalar loop would; a
  runtime-bound reference loop (which cannot peel, its bounds are variable)
  recomputes the same region for comparison. Bodies are sized into the peel
  window (a little too large for the generic unroller, inside the peel budget).}
program peel_basic_01;
{$mode objfpc}{$H+}

function f(i: longint): longint; inline;
begin
  f:=i*i + (i shl 2) - (i xor 3) + 1;
end;

procedure asc_const(var a: array of longint);
var i: longint;
begin
  { constant bounds 0..7 -> peels (trip 8) }
  for i:=0 to 7 do
    a[i]:=i*i + (i shl 2) - (i xor 3) + 1;
end;

procedure desc_const(var a: array of longint);
var i: longint;
begin
  { constant bounds 6 downto 2 -> peels (trip 5, descending) }
  for i:=6 downto 2 do
    a[i]:=i*i + (i shl 2) - (i xor 3) + 1;
end;

procedure ref_region(var a: array of longint; lo, hi: longint);
var i: longint;
begin
  { variable bounds -> never peeled: the scalar reference }
  for i:=lo to hi do
    a[i]:=f(i);
end;

var
  p, r: array[0..15] of longint;
  i: longint;
begin
  for i:=0 to 15 do begin p[i]:=-1; r[i]:=-1; end;

  asc_const(p);
  ref_region(r, 0, 7);
  for i:=0 to 7 do
    if p[i]<>r[i] then Halt(1);

  for i:=0 to 15 do begin p[i]:=-1; r[i]:=-1; end;
  desc_const(p);
  ref_region(r, 2, 6);
  for i:=2 to 6 do
    if p[i]<>r[i] then Halt(2);
  { indices outside the descending range must be untouched }
  if (p[0]<>-1) or (p[1]<>-1) or (p[7]<>-1) then Halt(3);

  writeln('ok');
end.
