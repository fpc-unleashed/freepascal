{ %OPT="-O4 -OoNOSTOREMERGE" %CHECKBIN_LACKS=Z7Q9 }
{ Gate test.  Identical out-of-order byte field initialisation as
  optstoremerge_correct_01, but with the store-merging peephole disabled via
  -OoNOSTOREMERGE.  The code generator alone does NOT coalesce this out-of-order
  shape, so the merged 32-bit immediate bytes "Z7Q9" must be absent from the
  binary (%CHECKBIN_LACKS).  Behaviour must still be identical -- the individual
  byte stores produce exactly the same memory contents. }
program optstoremerge_disabled_01;
{$mode objfpc}

type
  TByteRec = packed record a,b,c,d: byte; end;

function BuildLong: LongWord; noinline;
var r: TByteRec;
begin
  r.a:=$5A; r.c:=$51; r.b:=$37; r.d:=$39;
  Result := PLongWord(@r)^;
end;

var
  l: LongWord;
begin
  l := BuildLong;
  { no whole-value literal compare -- it would embed the Z7Q9 tag bytes }
  if PByte(@l)[0] <> $5A then Halt(2);
  if PByte(@l)[1] <> $37 then Halt(3);
  if PByte(@l)[2] <> $51 then Halt(4);
  if PByte(@l)[3] <> $39 then Halt(5);
  Writeln('OK');
end.
