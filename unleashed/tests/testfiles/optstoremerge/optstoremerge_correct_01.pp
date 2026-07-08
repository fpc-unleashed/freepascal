{ %OPT="-O4" %CHECKBIN_HAS=Z7Q9 }
{ Positive store-merging case.  Four out-of-order constant byte stores to a
  local record (address taken, so it stays in memory) are coalesced by the
  -OoSTOREMERGE peephole into a single 32-bit store; the composed little-endian
  immediate lays down the bytes 5A 37 51 39 which spell "Z7Q9" in the binary
  (asserted by %CHECKBIN_HAS -- a tag chosen so it does not occur elsewhere).
  The plain code generator does NOT merge this out-of-order shape (see
  optstoremerge_disabled_01), so the tag proves the peephole fired.  Every byte
  is read back individually to verify the value/endianness. }
program optstoremerge_correct_01;
{$mode objfpc}

type
  TByteRec = packed record a,b,c,d: byte; end;

{ out-of-order so codegen leaves separate movb; the peephole coalesces }
function BuildLong: LongWord; noinline;
var r: TByteRec;
begin
  r.a:=$5A; r.c:=$51; r.b:=$37; r.d:=$39;
  Result := PLongWord(@r)^;
end;

type
  TWordRec = packed record lo,hi: LongWord; end;

{ two 32-bit stores (hi before lo) coalesce into one 64-bit store; value fits a
  sign-extended imm32 so it is encodable as movq $imm32,mem }
function BuildQWord: QWord; noinline;
var r: TWordRec;
begin
  r.hi:=$00000000; r.lo:=$000000AA;
  Result := PQWord(@r)^;
end;

var
  l: LongWord;
  q: QWord;
begin
  l := BuildLong;
  { Read back each byte little-endian.  We deliberately do NOT compare the whole
    32-bit value against a literal, because that literal would embed the "Z7Q9"
    tag bytes contiguously and defeat the %CHECKBIN discriminator. }
  if PByte(@l)[0] <> $5A then Halt(2);
  if PByte(@l)[1] <> $37 then Halt(3);
  if PByte(@l)[2] <> $51 then Halt(4);
  if PByte(@l)[3] <> $39 then Halt(5);

  q := BuildQWord;
  if q <> QWord($00000000000000AA) then Halt(6);
  if PByte(@q)[0] <> $AA then Halt(7);
  if PByte(@q)[1] <> $00 then Halt(8);
  if PByte(@q)[7] <> $00 then Halt(9);

  Writeln('OK');
end.
