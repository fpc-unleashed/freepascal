program composable_records_union_of_overrides_01;

{$mode unleashed}

type
  TRec = record
    union of Byte size 4
      a: Byte;
      b: array[0..3] of Byte;
    end;
  end;

begin
  { `of Byte` defaults size to 1, but explicit `size 4` overrides;
    the resulting union must hold 4 bytes }
  if SizeOf(TRec) <> 4 then halt(1);
end.
