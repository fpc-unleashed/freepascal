{ %NORUN }
program fam_count_clause_01;

{$mode unleashed}

type
  TItem = record
    Tag: LongInt;
    Val: LongInt;
  end;

  PBatch = ^TBatch;
  TBatch = packed record
    Count:    LongWord;
    Reserved: LongWord;
    Items:    array[] of TItem count Count;
  end;

begin
  // syntax-only check: count clause must compile
  var b: PBatch;
  GetMem(b, SizeOf(TBatch) + 4 * SizeOf(TItem));
  b^.Count := 4;
  FreeMem(b);
end.
