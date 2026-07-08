{ %OPT="-O4" }
{ Negative store-merging cases: every one must stay correct at -O4.  A silent
  mis-merge here would corrupt the read-back values and Halt with the case
  number.  The barriers exercised:
    * a call (Writeln) between two field stores           -> run broken by call
    * a store through an unrelated pointer between fields  -> different base
    * overlapping stores to the same offset               -> order-sensitive
    * non-adjacent offsets (a hole between the stores)     -> window not tiled }
program optstoremerge_negatives_01;
{$mode objfpc}

type
  TByteRec = packed record a,b,c,d: byte; end;

{ a call sits between the two halves of the initialisation }
function CallBetween: LongWord; noinline;
var r: TByteRec;
begin
  r.a:=$4D; r.b:=$52;
  Write('');            { call between stores: must not merge across it }
  r.c:=$47; r.d:=$44;
  Result := PLongWord(@r)^;
end;

{ a store through an unrelated pointer sits between two field stores }
function AliasWrite(p: PByte): LongWord; noinline;
var r: TByteRec;
begin
  r.a:=$4D;
  p^ := $99;             { potentially-aliasing store to a different base }
  r.b:=$52; r.c:=$47; r.d:=$44;
  Result := PLongWord(@r)^;
end;

{ two stores to the SAME offset (overlap): the last writer must win }
function Overlap: byte; noinline;
var r: TByteRec;
begin
  r.a:=$11;
  r.a:=$22;              { overwrites: final value must be $22 }
  r.b:=$33;
  Result := PByte(@r)[0];
end;

{ non-adjacent: a and z straddle an 8-byte hole, cannot tile a window }
function NonAdjacent: word; noinline;
var r: packed record a: byte; gap: array[0..7] of byte; z: byte; end;
begin
  r.a:=$4D; r.z:=$44;
  Result := PByte(@r)[0] + PByte(@r)[9];
end;

var
  g: byte;
begin
  if CallBetween <> $4447524D then Halt(1);
  g := 0;
  if AliasWrite(@g) <> $4447524D then Halt(2);
  if g <> $99 then Halt(3);
  if Overlap <> $22 then Halt(4);
  if NonAdjacent <> ($4D + $44) then Halt(5);
  Writeln('OK');
end.
