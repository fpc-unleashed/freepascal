program preproc_intrinsic_bitalignof_01;
{$mode unleashed}

// `{$if BitAlignOf(T) ...}` in preprocessor evaluator: alignment * 8
type
  TFour = record
    a, b: Word;  // 4 bytes, alignment 2 -> 16 bits
  end;

{$if BitAlignOf(TFour) <> 16} {$error BitAlignOf(TFour) should be 16} {$endif}
{$if BitAlignOf(Byte) <> 8} {$error BitAlignOf(Byte) should be 8} {$endif}
{$if BitAlignOf(LongInt) <> 32} {$error BitAlignOf(LongInt) should be 32} {$endif}

begin
end.
