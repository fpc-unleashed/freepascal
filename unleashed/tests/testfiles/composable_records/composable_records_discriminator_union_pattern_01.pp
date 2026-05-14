program composable_records_discriminator_union_pattern_01;

{$mode unleashed}

type
  TKind = (kAudio, kVideo, kCtrl);
  TPacket = record
    kind: TKind;
    union
      record codec, channels: Byte; sample_rate: Word; end;
      record codec_video: Byte; width, height: Word; end;
      ctrl: record cmd, status: Word; end;
    end;
    crc: LongWord;
  end;

var
  p: TPacket;
begin
  p.kind := kAudio;
  p.codec := 1;
  p.channels := 2;
  p.sample_rate := 44100;
  p.crc := $DEADBEEF;
  if p.kind <> kAudio then halt(1);
  if p.codec <> 1 then halt(2);
  if p.sample_rate <> 44100 then halt(3);

  { overlay - codec_video shares the same offset as codec }
  p.codec_video := 99;
  if p.codec <> 99 then halt(4);

  { named subfield ctrl is NOT flattened, accessed via p.ctrl.X }
  p.ctrl.cmd := 7;
  if p.ctrl.cmd <> 7 then halt(5);
end.
