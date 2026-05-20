program composable_records_statarray_union_01;

{$mode unleashed}

type
  TIPv4 = record
    union
      whole: LongWord;
      octets: array[0..3] of Byte;
    end;
  end;

var
  arr: array[0..1] of TIPv4;
begin
  arr[0].whole := $7f000001;
  arr[1].whole := $c0a80001;
  if arr[0].octets[0] <> $01 then halt(1);
  if arr[0].octets[3] <> $7f then halt(2);
  if arr[1].octets[0] <> $01 then halt(3);
  if arr[1].octets[3] <> $c0 then halt(4);
end.
