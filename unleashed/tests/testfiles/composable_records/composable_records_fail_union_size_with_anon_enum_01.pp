{ %FAIL }
program composable_records_fail_union_size_with_anon_enum_01;
{ a too-wide anonymous-enum field inside `union of Byte` (1-byte
  budget) used to emit the real size-mismatch diagnostic AND then
  trip IE 200601272 in insertunionst when the anon-enum constants
  failed `is_normal_fieldvarsym`. now stops at the real error. }

{$mode unleashed}

type
  TPacket = record
    union of Byte kind: (kAudio, kVideo, kCtrl); end;
    crc: longword;
  end;

begin
end.
