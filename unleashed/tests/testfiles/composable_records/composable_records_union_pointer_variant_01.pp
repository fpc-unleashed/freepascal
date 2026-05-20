program composable_records_union_pointer_variant_01;

{$mode unleashed}

type
  TRec = record
    union
      p: Pointer;
      n: PtrUInt;
    end;
  end;

var
  r: TRec;
  x: LongInt;
begin
  x := 123;
  r.p := @x;
  if r.n <> PtrUInt(@x) then halt(1);
  if SizeOf(TRec) <> SizeOf(Pointer) then halt(2);
end.
