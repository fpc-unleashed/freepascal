program composable_records_perfield_enum_align_01;
{ per-field `align N` continues to work on an enum field - alignment only
  ever bumps up, no truncation hazard. }

{$mode unleashed}

type
  TKind = (kA, kB, kC);
  TR = record
    pad: Byte;
    kind: TKind align 16;
  end;

begin
  if OffsetOf(TR.kind) <> 16 then halt(1);
end.
