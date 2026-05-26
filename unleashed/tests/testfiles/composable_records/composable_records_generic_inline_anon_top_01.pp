program composable_records_generic_inline_anon_top_01;

{$mode unleashed}

type
  { inline anonymous record at top of a generic record body - the
    specialisation pass needs the matching composition entry from the
    generic def as a hint, otherwise the nested record_dec crashes }
  TBox<T> = record
    item: T;
    record
      a, b: Byte;
    end;
  end;

var
  b: TBox<LongWord>;
begin
  b.item := $DEADBEEF;
  b.a := 1;
  b.b := 2;
  if b.item <> $DEADBEEF then halt(1);
  if b.a <> 1 then halt(2);
  if b.b <> 2 then halt(3);
end.
