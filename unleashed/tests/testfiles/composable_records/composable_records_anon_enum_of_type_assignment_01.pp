program composable_records_anon_enum_of_type_assignment_01;
{ a 1-byte-storage anonymous enum field really only occupies one byte:
  the adjacent sentinel field stays intact across a write. }

{$mode unleashed}

type
  TR = packed record
    kind:     (kAudio, kVideo, kCtrl) of Byte;
    sentinel: LongWord;
  end;

var
  r: TR;
begin
  r.sentinel := $DEADBEEF;
  r.kind := TR.kCtrl;
  if Ord(r.kind) <> 2 then halt(1);
  if r.sentinel <> $DEADBEEF then halt(2);
end.
