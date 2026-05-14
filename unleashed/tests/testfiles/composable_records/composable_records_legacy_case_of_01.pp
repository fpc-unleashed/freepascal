program composable_records_legacy_case_of_01;

{$mode unleashed}

type
  { stock Pascal `case TYPE of` variants must keep working even with
    composablerecords active }
  TLegacy = record
    a: Integer;
    case Byte of
      0: (b: Integer);
      1: (c: PChar);
  end;

var
  r: TLegacy;
begin
  r.a := 10;
  r.b := 20;
  if r.a <> 10 then halt(1);
  if r.b <> 20 then halt(2);
end.
