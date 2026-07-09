{ %OPT="-O2" }
{ Companion to opticf_semantics_01: same source, ICF OFF (plain -O2).  With no
  folding, neither Alpha nor Beta is rewritten into a jmp thunk, so NONE of the
  three routines begins with the near-jmp opcode 0xE9.  Results and address
  distinctness are of course still correct. }
program opticf_disabled_01;
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

  if ra <> rb then Halt(1);
  if rg = ra then Halt(2);

  folds := 0;
  if StartsWithJmp(@Alpha) then Inc(folds);
  if StartsWithJmp(@Beta) then Inc(folds);
  if StartsWithJmp(@Gamma) then Inc(folds);
  { ICF off: nothing folded to a thunk }
  if folds <> 0 then Halt(3);

  Writeln('OK');
end.
