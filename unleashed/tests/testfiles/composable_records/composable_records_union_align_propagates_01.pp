program composable_records_union_align_propagates_01;

{$mode unleashed}

type
  { explicit `union align N` must bump the surrounding record's
    alignment too - otherwise AlignOf(outer) silently drops to the
    platform default and cache-line guards stop working }
  TRec = record
    union align 64
      v: int64;
    end;
  end;

  TBitRec = record
    union bitalign 64
      v: int64;
    end;
  end;

begin
  if AlignOf(TRec) <> 64 then halt(1);
  if AlignOf(TBitRec) <> 8 then halt(2);   { bitalign 64 = ceil(64/8) = 8 }
end.
