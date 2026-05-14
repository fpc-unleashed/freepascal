{ %FAIL }
program composable_records_fail_anon_enum_leak_01;

{$mode unleashed}

type
  TFoo = record
    kind: (kA, kB, kC);
  end;

var
  f: TFoo;
begin
  { in composablerecords mode anonymous enum constants stay scoped to
    the record - reaching `kA` unqualified from outside the record is
    a compile error, the unit's symbol table stays clean }
  f.kind := kA;
end.
