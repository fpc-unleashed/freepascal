program composable_records_union_packed_layout_01;

{$mode unleashed}

type
  { unions in a packed record lay out back to back - a variant's natural
    alignment must not over-align the unions that follow it }
  TRegs = packed record
    union flags: QWord; packed record c, z: boolean; end; end;
    union dbr: LongWord; packed record db: Byte; end; end;
    union pc: Word; packed record pcl, pch: Byte; end; end;
    md: Byte;
  end;

begin
  if SizeOf(TRegs) <> 15 then halt(1);
  if OffsetOf(TRegs.flags) <> 0 then halt(2);
  if OffsetOf(TRegs.dbr) <> 8 then halt(3);
  if OffsetOf(TRegs.pc) <> 12 then halt(4);
  if OffsetOf(TRegs.md) <> 14 then halt(5);
end.
