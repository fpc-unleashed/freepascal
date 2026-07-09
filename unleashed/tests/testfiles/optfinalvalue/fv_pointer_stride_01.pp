{ %OPT="-O2 -OoFINALVALUE" }
{ -OoFINALVALUE pointer-stride accumulators: a counted loop whose body advances
  a plain local pointer by a loop-invariant stride  inc(p,stride) / dec(p,stride)
  / inc(p)  is replaced by the closed form  p := p + (b-a+1)*stride , built as a
  pointer+integer add so the compiler applies the same element-size scaling the
  loop body did. Covered for typed (4-byte element) and byte (PChar) pointers,
  unit and non-unit strides, increment and decrement, ascending and downto, and
  zero-trip (a>b) loops -- all checked bit-exact against a direct reference. }
program fv_pointer_stride_01;
{$mode objfpc}{$H+}

type
  PLongint = ^Longint;

const
  ES = SizeOf(Longint);   { typed-pointer element size }

{ inc(p,stride), ascending }
function inc_up(base: PLongint; n, stride: longint): PtrInt;
var i: longint; p: PLongint;
begin
  p:=base;
  for i:=1 to n do inc(p,stride);
  inc_up:=PtrInt(p)-PtrInt(base);
end;

{ inc(p,stride), downto (zero-trip when n<1) }
function inc_down(base: PLongint; n, stride: longint): PtrInt;
var i: longint; p: PLongint;
begin
  p:=base;
  for i:=n downto 1 do inc(p,stride);
  inc_down:=PtrInt(p)-PtrInt(base);
end;

{ dec(p,stride): pointer walks backward }
function dec_p(base: PLongint; n, stride: longint): PtrInt;
var i: longint; p: PLongint;
begin
  p:=base;
  for i:=1 to n do dec(p,stride);
  dec_p:=PtrInt(base)-PtrInt(p);
end;

{ inc(p): implicit unit stride }
function inc_one(base: PLongint; n: longint): PtrInt;
var i: longint; p: PLongint;
begin
  p:=base;
  for i:=1 to n do inc(p);
  inc_one:=PtrInt(p)-PtrInt(base);
end;

{ byte-granular pointer (PChar): element size 1 }
function pchar_stride(base: PChar; n, stride: longint): PtrInt;
var i: longint; p: PChar;
begin
  p:=base;
  for i:=1 to n do inc(p,stride);
  pchar_stride:=PtrInt(p)-PtrInt(base);
end;

var
  buf: array[0..4096] of longint;
  base: PLongint;
  n, stride: longint;
begin
  base:=@buf[4096];   { start high so backward walks stay in-bounds addresses }
  for n:=0 to 40 do
    for stride:=1 to 5 do
      begin
        if inc_up(base,n,stride)   <> n*stride*ES then Halt(1);
        { for i:=n downto 1 runs max(0,n) times; n>=0 here so = n }
        if inc_down(base,n,stride) <> n*stride*ES then Halt(2);
        if dec_p(base,n,stride)    <> n*stride*ES then Halt(3);
        if pchar_stride(PChar(base),n,stride) <> n*stride then Halt(5);
      end;
  for n:=0 to 40 do
    if inc_one(base,n) <> n*ES then Halt(4);
  Halt(0);
end.
