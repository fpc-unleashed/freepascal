program composable_records_mixed_embed_with_case_01;

{$mode unleashed}

type
  THeader = record
    magic: LongWord;
    len: Word;
  end;

  TRec = record
    embed THeader;
    case Byte of
      0: (asint: LongInt);
      1: (asbytes: array[0..3] of Byte);
  end;

var
  r: TRec;
begin
  r.magic := $DEADBEEF;
  r.len := 4;
  r.asint := $11223344;
  if r.magic <> $DEADBEEF then halt(1);
  if r.len <> 4 then halt(2);
  if r.asbytes[0] <> $44 then halt(3);
end.
