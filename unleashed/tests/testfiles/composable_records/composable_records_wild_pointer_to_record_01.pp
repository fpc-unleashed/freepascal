program composable_records_wild_pointer_to_record_01;

{$mode unleashed}

type
  TInner = record a, b: LongInt; end;
  TOuter = record embed TInner; c: LongInt; end;
  POuter = ^TOuter;

var
  p: POuter;
  storage: TOuter;
begin
  p := @storage;
  p^.a := 11;
  p^.b := 22;
  p^.c := 33;
  if p^.a <> 11 then halt(1);
  if p^.b <> 22 then halt(2);
  if p^.c <> 33 then halt(3);
end.
