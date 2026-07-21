program composable_records_property_union_anon_field_01;

{$mode unleashed}

type
  TFoo = record
    union
      YX: Word;
      packed record
        LowB, HighB: Byte;
      end;
    end;
    property X: Byte read LowB write LowB;
    property Y: Byte read HighB write HighB;
    property Both: Word read YX write YX;
  end;

var
  foo: TFoo;
begin
  foo.YX := $1234;
  if foo.X <> $34 then halt(1);
  if foo.Y <> $12 then halt(2);
  if foo.Both <> $1234 then halt(3);
  foo.X := $78;
  foo.Y := $56;
  if foo.YX <> $5678 then halt(4);
end.
