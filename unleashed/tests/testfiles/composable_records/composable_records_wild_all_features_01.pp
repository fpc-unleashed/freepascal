program composable_records_wild_all_features_01;

{$mode unleashed}

type
  THeader = record
    magic: LongWord;
    version: Word;
  end;

  TRec = packed record
    embed THeader;
    flags: Byte;
    union of Byte size 4
      raw: LongWord;
      bits: bitpacked record of Boolean
        b0, b1, b2, b3, b4, b5, b6, b7: 1;
        pad 24;
      end;
    end;
    tail: Byte;
  end;

var
  r: TRec;
begin
  r.magic := $DEADBEEF;
  r.version := 1;
  r.flags := $AA;
  r.raw := 0;
  r.bits.b0 := True;
  r.bits.b2 := True;
  r.tail := $FF;

  if r.magic <> $DEADBEEF then halt(1);
  if r.version <> 1 then halt(2);
  if r.flags <> $AA then halt(3);
  if r.raw <> $00000005 then halt(4);
  if r.tail <> $FF then halt(5);
  if SizeOf(TRec) <> SizeOf(THeader) + 1 + 4 + 1 then halt(6);
end.
