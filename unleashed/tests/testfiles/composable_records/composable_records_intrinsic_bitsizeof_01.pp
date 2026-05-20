program composable_records_intrinsic_bitsizeof_01;

{$mode unleashed}

type
  TPack = bitpacked record
    a: Byte bitsize 3;
    b: Byte;
  end;

begin
  if BitSizeOf(TPack.a) <> 3 then halt(1);   { honours per-field bitsize }
  if BitSizeOf(TPack.b) <> 8 then halt(2);   { full byte }
end.
