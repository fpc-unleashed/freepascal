program composable_records_with_union_01;

{$mode unleashed}

type
  TIPv4 = record
    union
      whole: LongWord;
      octets: array[0..3] of Byte;
    end;
  end;

var
  ip: TIPv4;
begin
  ip.whole := $7f000001;
  with ip do
    begin
      if whole <> $7f000001 then halt(1);
      { little-endian octets }
      if octets[0] <> $01 then halt(2);
      if octets[3] <> $7f then halt(3);
    end;
end.
