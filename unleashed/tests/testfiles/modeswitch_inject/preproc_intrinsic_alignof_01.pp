program preproc_intrinsic_alignof_01;
{$mode unleashed}

// `{$if AlignOf(T) ...}` now works in the preprocessor evaluator,
// alongside the existing SizeOf
type
  TFour = record
    a, b: Word;  // 4 bytes, 2-byte alignment
  end;

{$if AlignOf(TFour) <> 2} {$error AlignOf(TFour) should be 2} {$endif}
{$if AlignOf(Byte) <> 1} {$error AlignOf(Byte) should be 1} {$endif}
{$if AlignOf(LongInt) <> 4} {$error AlignOf(LongInt) should be 4} {$endif}

begin
end.
