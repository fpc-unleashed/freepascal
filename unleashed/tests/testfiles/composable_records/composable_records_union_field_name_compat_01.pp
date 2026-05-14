program composable_records_union_field_name_compat_01;

{$mode unleashed}

type
  { keyword 'union' must still parse as a field name when followed by ':' }
  TRec = record
    union: LongInt;
    other: Byte;
  end;

var
  r: TRec;
begin
  r.union := 42;
  r.other := 7;
  if r.union <> 42 then halt(1);
  if r.other <> 7 then halt(2);
end.
