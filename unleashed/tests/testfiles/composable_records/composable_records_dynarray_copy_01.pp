program composable_records_dynarray_copy_01;

{$mode unleashed}

type
  TFoo = record
    union
      whole: LongWord;
      octets: array[0..3] of Byte;
    end;
  end;

var
  a, b: array of TFoo;
begin
  SetLength(a, 2);
  a[0].whole := $11223344;
  a[1].whole := $aabbccdd;
  { value copy via Copy() }
  b := Copy(a);
  if Length(b) <> 2 then halt(1);
  if b[0].whole <> $11223344 then halt(2);
  if b[1].whole <> $aabbccdd then halt(3);
  { mutate b, a unchanged }
  b[0].whole := 0;
  if a[0].whole <> $11223344 then halt(4);
end.
