program preproc_intrinsic_bitsizeof_01;
{$mode unleashed}

// `{$if BitSizeOf(T) ...}` in preprocessor evaluator
type
  TEight = record
    x, y: LongInt;  // 8 bytes = 64 bits
  end;

{$if BitSizeOf(TEight) <> 64} {$error BitSizeOf(TEight) should be 64} {$endif}
{$if BitSizeOf(Byte) <> 8} {$error BitSizeOf(Byte) should be 8} {$endif}
{$if BitSizeOf(Word) <> 16} {$error BitSizeOf(Word) should be 16} {$endif}

begin
end.
