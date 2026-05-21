program preproc_intrinsic_bitoffsetof_01;
{$mode unleashed}

// `{$if BitOffsetOf(T.field[.subfield...]) ...}` in preproc evaluator;
// same walk as OffsetOf but value in BITS
type
  TInner = record
    a: Byte;
    b: Word;
  end;

  TOuter = record
    pad: Word;
    inner: TInner;
  end;

{$if BitOffsetOf(TOuter.pad) <> 0} {$error BitOffsetOf(TOuter.pad) should be 0} {$endif}
{$if BitOffsetOf(TOuter.inner) <> 16} {$error BitOffsetOf(TOuter.inner) should be 16} {$endif}
{$if BitOffsetOf(TOuter.inner.b) <> 32} {$error TOuter.inner.b bits should be 32} {$endif}

begin
end.
