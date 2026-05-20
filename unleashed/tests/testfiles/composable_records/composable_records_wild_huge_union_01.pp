program composable_records_wild_huge_union_01;

{$mode unleashed}

type
  TBig = record
    union align 64 size 128
      payload: array[0..127] of Byte;
    end;
  end;

begin
  if SizeOf(TBig) <> 128 then halt(1);
  { the union itself carries align 64, but TBig (the surrounding record)
    only inherits up to its own recordalignmax clamp; verify the union
    sets its variant size correctly }
end.
