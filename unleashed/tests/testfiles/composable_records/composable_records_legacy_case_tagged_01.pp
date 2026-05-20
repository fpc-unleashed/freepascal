program composable_records_legacy_case_tagged_01;

{$mode unleashed}

type
  TTag = (tInt, tFloat);
  TTagged = record
    case kind: TTag of
      tInt:   (i: LongInt);
      tFloat: (f: Single);
  end;

var
  v: TTagged;
begin
  v.kind := tInt;
  v.i := 42;
  if v.kind <> tInt then halt(1);
  if v.i <> 42 then halt(2);
end.
