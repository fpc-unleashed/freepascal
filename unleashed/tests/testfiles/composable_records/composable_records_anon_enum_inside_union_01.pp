program composable_records_anon_enum_inside_union_01;
{ anonymous enum declared as a field inside a `union` body. the
  enum constants are scoped to the outer record (TPacket.kAudio),
  the union itself carries the discriminator. previously tripped
  IE 200601272 in insertunionst because the enumsyms were not
  fieldvarsyms. }

{$mode unleashed}

type
  TPacket = record
    union of Int64 kind: (kAudio, kVideo, kCtrl); end;
  end;

var
  p: TPacket;
begin
  p.kind := TPacket.kVideo;
  if Ord(p.kind) <> 1 then halt(1);
  p.kind := TPacket.kCtrl;
  if Ord(p.kind) <> 2 then halt(2);
  if Ord(TPacket.kAudio) <> 0 then halt(3);
  if SizeOf(TPacket) <> 8 then halt(4);
end.
