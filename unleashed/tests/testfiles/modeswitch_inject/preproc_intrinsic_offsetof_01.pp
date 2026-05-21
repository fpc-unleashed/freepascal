program preproc_intrinsic_offsetof_01;
{$mode unleashed}

// `{$if OffsetOf(T.field[.subfield...]) ...}` in preproc evaluator;
// walks dot-chain through nested records, value in BYTES
type
  TInner = record
    a: Byte;
    b: Word;
  end;

  TOuter = record
    pad: Word;       // offset 0
    inner: TInner;   // offset 2
  end;

{$if OffsetOf(TOuter.pad) <> 0} {$error OffsetOf(TOuter.pad) should be 0} {$endif}
{$if OffsetOf(TOuter.inner) <> 2} {$error OffsetOf(TOuter.inner) should be 2} {$endif}
{$if OffsetOf(TOuter.inner.a) <> 2} {$error TOuter.inner.a should be 2} {$endif}
{$if OffsetOf(TOuter.inner.b) <> 4} {$error TOuter.inner.b should be 4} {$endif}

// comma-separator form also supported (C-style)
{$if OffsetOf(TOuter,inner,b) <> 4} {$error comma-form failed} {$endif}

begin
end.
