{ %OPT="-O2 -OoICF" }
{ Identical Code Folding (-OoICF), fold-happens + semantics case.
  Alpha and Beta have byte-identical bodies, so ICF folds one of them into a
  jmp thunk to the other; Gamma differs by one operation and must NOT fold.
  The test asserts (a) all three compute the right value, (b) their addresses
  stay pairwise distinct (the fold is a thunk, never an alias, so @Alpha<>@Beta
  survives), and (c) folding actually happened: exactly one of Alpha/Beta now
  begins with the x86 near-jmp opcode 0xE9, while Gamma does not.
  Companion opticf_disabled_01 compiles the same source with ICF off and
  asserts NO routine was turned into a jmp thunk. }
program opticf_semantics_01;
{$mode objfpc}

function Alpha(a,b,c,d: longint): longint; noinline;
begin
  result:=a*b+c-d; result:=result*a; result:=result xor b;
  result:=result+c*d; result:=result-a*c; result:=result or d;
  result:=result*3+7; result:=result and $7f; result:=result shl 2;
end;

function Beta(a,b,c,d: longint): longint; noinline;
begin
  result:=a*b+c-d; result:=result*a; result:=result xor b;
  result:=result+c*d; result:=result-a*c; result:=result or d;
  result:=result*3+7; result:=result and $7f; result:=result shl 2;
end;

function Gamma(a,b,c,d: longint): longint; noinline;
begin
  result:=a*b+c-d; result:=result*c; result:=result xor b;   { *c not *a }
  result:=result+c*d; result:=result-a*c; result:=result or d;
  result:=result*3+7; result:=result and $7f; result:=result shl 2;
end;

function StartsWithJmp(p: Pointer): boolean;
begin
  StartsWithJmp := PByte(p)^ = $E9;
end;

var
  ra, rb, rg, folds: longint;
begin
  ra := Alpha(2,3,4,5);
  rb := Beta(2,3,4,5);
  rg := Gamma(2,3,4,5);

  { Alpha and Beta are byte-identical, so must return the same value }
  if ra <> rb then Halt(1);
  { Gamma differs, so must return a different value }
  if rg = ra then Halt(2);

  { addresses must stay pairwise distinct even after folding }
  if ptruint(@Alpha) = ptruint(@Beta) then Halt(3);
  if ptruint(@Alpha) = ptruint(@Gamma) then Halt(4);
  if ptruint(@Beta) = ptruint(@Gamma) then Halt(5);

  { exactly one of Alpha/Beta must have been folded into a jmp thunk }
  folds := 0;
  if StartsWithJmp(@Alpha) then Inc(folds);
  if StartsWithJmp(@Beta) then Inc(folds);
  if folds <> 1 then Halt(6);

  { Gamma is not a fold candidate for this pair and must keep its own body }
  if StartsWithJmp(@Gamma) then Halt(7);

  Writeln('OK');
end.
