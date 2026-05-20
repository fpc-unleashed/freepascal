program composable_records_pointer_union_01;

{$mode unleashed}

type
  TIPv4 = record
    union
      whole: LongWord;
      octets: array[0..3] of Byte;
    end;
  end;
  PIPv4 = ^TIPv4;

var
  p: PIPv4;
begin
  New(p);
  try
    p^.whole := $11223344;
    if p^.whole <> $11223344 then halt(1);
    { little-endian: low byte = $44 }
    if p^.octets[0] <> $44 then halt(2);
    if p^.octets[3] <> $11 then halt(3);
  finally
    Dispose(p);
  end;
end.
