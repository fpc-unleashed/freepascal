program composable_records_assignment_via_union_01;

{$mode unleashed}

type
  TFoo = record
    union
      whole: LongWord;
      octets: array[0..3] of Byte;
    end;
  end;

var
  a, b: TFoo;
begin
  a.whole := $deadbeef;
  b := a;
  if b.whole <> $deadbeef then halt(1);
  if b.octets[0] <> $ef then halt(2);
  if b.octets[3] <> $de then halt(3);
  { write to b.octets, b.whole reflects }
  b.octets[0] := $11;
  if b.whole <> $deadbe11 then halt(4);
  { a remains untouched }
  if a.whole <> $deadbeef then halt(5);
end.
