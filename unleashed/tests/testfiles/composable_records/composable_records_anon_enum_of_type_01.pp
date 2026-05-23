program composable_records_anon_enum_of_type_01;
{ `(kA, kB, kC) of T` shrinks the anonymous enum's storage to T's
  natural size. mirrors `union of T` / `bitpacked record of T`. }

{$mode unleashed}

type
  TByte = record kind: (kA, kB, kC) of Byte; end;
  TWord = record kind: (k0, k1, k2, k3) of Word; end;
  TLong = record kind: (kFoo, kBar) of LongWord; end;
  TBig  = record kind: (kX, kY) of Int64; end;

begin
  if SizeOf(TByte) <> 1 then halt(1);
  if SizeOf(TWord) <> 2 then halt(2);
  if SizeOf(TLong) <> 4 then halt(3);
  if SizeOf(TBig)  <> 8 then halt(4);
end.
