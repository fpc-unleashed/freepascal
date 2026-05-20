program composable_records_union_overrides_align_from_of_01;

{$mode unleashed}

type
  { explicit `align 16` after `of Byte` widens the union slot beyond
    the Byte-derived default of 1. payload remains 1 byte (single Byte
    variant), so the resulting size must equal align padding inside
    the surrounding record. }
  TRec = packed record
    leader: Byte;
    union of Byte align 8 size 8
      a: Byte;
    end;
  end;

begin
  { leader at 0, union aligned to 8 -> starts at 8, payload 8 bytes;
    so total is 16 }
  if SizeOf(TRec) <> 16 then halt(1);
end.
