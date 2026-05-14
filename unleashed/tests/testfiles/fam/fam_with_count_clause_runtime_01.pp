program fam_with_count_clause_runtime_01;

{$mode unleashed}

type
  TItem = record
    a, b: Integer;
  end;

  PBatch = ^TBatch;
  TBatch = packed record
    Count:    LongWord;
    Reserved: LongWord;
    Items:    array[] of TItem count Count;
  end;

const
  N = 5;

begin
  var b: PBatch;
  GetMem(b, SizeOf(TBatch) + N * SizeOf(TItem));
  b^.Count := N;
  b^.Reserved := 0;
  for var i := 0 to N - 1 do
  begin
    b^.Items[i].a := i;
    b^.Items[i].b := i * 10;
  end;
  for var i := 0 to N - 1 do
  begin
    if b^.Items[i].a <> i      then halt(1);
    if b^.Items[i].b <> i * 10 then halt(2);
  end;
  FreeMem(b);
end.
