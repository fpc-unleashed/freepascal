program composable_records_union_packrecords_layout_01;

{$mode unleashed}
{$PackRecords 2}

type
  { the packrecords value caps union alignment for every union, also
    after a union whose variants have a larger natural alignment }
  TFoo = record
    union a: QWord; packed record al, ah: LongWord; end; end;
    union b: Word; packed record bl, bh: Byte; end; end;
    union c: LongWord; packed record cl, ch: Word; end; end;
  end;

begin
  if OffsetOf(TFoo.a) <> 0 then halt(1);
  if OffsetOf(TFoo.b) <> 8 then halt(2);
  if OffsetOf(TFoo.c) <> 10 then halt(3);
  if SizeOf(TFoo) <> 14 then halt(4);
end.
