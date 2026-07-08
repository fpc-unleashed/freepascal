{ %OPT="-O4" }
{ Endianness of the little-endian constant composition, verified by reading back
  every individual byte after the merge.  Two adjacent byte stores coalesce into
  one 16-bit store; two adjacent 16-bit stores coalesce into one 32-bit store.
  Each distinct byte value must land at exactly its own offset. }
program optstoremerge_endian_01;
{$mode objfpc}

type
  TByteRec = packed record a,b: byte; end;
  TWordRec = packed record x,y: word; end;

{ two byte stores -> one word store }
function BuildWord: word; noinline;
var r: TByteRec;
begin
  r.a:=$CD; r.b:=$AB;         { little-endian => word $ABCD }
  Result := PWord(@r)^;
end;

{ two word stores (high half first) -> one dword store }
function BuildLongFromWords: LongWord; noinline;
var r: TWordRec;
begin
  r.y:=$DEAD; r.x:=$BEEF;      { little-endian => $DEADBEEF }
  Result := PLongWord(@r)^;
end;

var
  w: word;
  l: LongWord;
begin
  w := BuildWord;
  if w <> $ABCD then Halt(1);
  if PByte(@w)[0] <> $CD then Halt(2);
  if PByte(@w)[1] <> $AB then Halt(3);

  l := BuildLongFromWords;
  if l <> $DEADBEEF then Halt(4);
  if PByte(@l)[0] <> $EF then Halt(5);
  if PByte(@l)[1] <> $BE then Halt(6);
  if PByte(@l)[2] <> $AD then Halt(7);
  if PByte(@l)[3] <> $DE then Halt(8);

  Writeln('OK');
end.
