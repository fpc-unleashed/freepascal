program composable_records_anon_enum_qualified_01;

{$mode unleashed}

type
  TFoo = record
    kind: (kA, kB, kC);
  end;

var
  f: TFoo;
begin
  f.kind := TFoo.kA;
  if Ord(f.kind) <> 0 then halt(1);
  f.kind := TFoo.kC;
  if Ord(f.kind) <> 2 then halt(2);
end.
