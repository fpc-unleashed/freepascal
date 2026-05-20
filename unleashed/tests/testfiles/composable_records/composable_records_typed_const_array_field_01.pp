program composable_records_typed_const_array_field_01;

{$mode unleashed}

type
  TBuf = record
    union
      data: array[0..3] of Byte;
      whole: LongWord;
    end;
  end;

const
  k: TBuf = (data: ($de, $ad, $be, $ef));

begin
  if k.data[0] <> $de then halt(1);
  if k.data[3] <> $ef then halt(2);
  { little-endian readback through union }
  if k.whole <> $efbeadde then halt(3);
end.
