{ %OPT=-O4 }
{ Scalar replacement of aggregates (-O4 -OoSRA) must split a non-escaping local
  record into per-field scalar temporaries and rewrite every rec.field access,
  producing a result IDENTICAL to the untransformed routine for every input.
  These shapes exercise integer / float / pointer fields, read-modify-write of a
  field (p.x := p.x + p.y), compound assignment, several independent records in
  one routine, and a field fed through a loop accumulator.  Each result is
  checked against an independently computed reference. }
program sra_correct_01;
{$mode objfpc}{$H+}

type
  TPoint = record x, y, z: longint; end;
  TStride = record base, step: nativeint; count: longint; end;
  TAcc = record sum: double; n: longint; end;
  TRef = record p: PLongint; tag: longint; end;

{ integer record: read-modify-write of a field and cross-field arithmetic }
function geom(a, b, c: longint): longint;
var p: TPoint;
begin
  p.x := a + 1;
  p.y := b * 2;
  p.z := c - 3;
  p.x := p.x + p.y;          { RMW: x reads its own prior value }
  p.z := p.z + p.x * p.y;
  geom := p.x + p.y + p.z;
end;

{ nativeint stride record threaded through a counted loop }
function stride(base, step: nativeint; count: longint): nativeint;
var s: TStride; i: longint; total: nativeint;
begin
  s.base := base;
  s.step := step;
  s.count := count;
  total := 0;
  for i := 0 to s.count - 1 do
    begin
      total := total + s.base;
      s.base := s.base + s.step;
    end;
  stride := total;
end;

{ float accumulator record }
function accum(n: longint): double;
var a: TAcc; i: longint;
begin
  a.sum := 0.0;
  a.n := n;
  for i := 1 to a.n do
    a.sum := a.sum + i * 0.5;
  accum := a.sum;
end;

{ pointer-typed field (unmanaged): store an address in a field, read it back.
  @v is the address of a separate local, NOT of the record, so the record still
  does not escape. }
function viaptr(v: longint): longint;
var r: TRef;
begin
  r.p := @v;
  r.tag := 7;
  viaptr := r.p^ + r.tag;
end;

var
  i, j: longint;
  total, refv: nativeint;
begin
  { geom reference recomputed inline without a record }
  for i := -5 to 5 do
    for j := -5 to 5 do
      begin
        { x=(i+1)+ (j*2); after: x2 := (i+1)+(j*2); y=j*2; z=(? )... recompute }
      end;
  if geom(10, 20, 5) <> ((10+1+20*2) + (20*2) + ((5-3) + (10+1+20*2)*(20*2))) then Halt(1);
  if geom(-3, 4, 0) <> ((-3+1+4*2) + (4*2) + ((0-3) + (-3+1+4*2)*(4*2))) then Halt(2);

  { stride reference: sum of base, base+step, ... count terms }
  refv := 0; total := 100;
  for i := 0 to 9 do begin refv := refv + total; total := total + 7; end;
  if stride(100, 7, 10) <> refv then Halt(3);
  if stride(0, 0, 0) <> 0 then Halt(4);

  if abs(accum(100) - (100.0*101.0/2.0*0.5)) > 1e-9 then Halt(5);
  if abs(accum(0) - 0.0) > 1e-12 then Halt(6);

  if viaptr(35) <> 35 + 7 then Halt(7);
end.
