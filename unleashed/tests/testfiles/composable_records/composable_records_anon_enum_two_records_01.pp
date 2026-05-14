program composable_records_anon_enum_two_records_01;

{$mode unleashed}

type
  { same enumerator names in two different records must not clash -
    each set lives in its own record's scope }
  TFirst = record
    kind: (kA, kB, kC);
  end;

  TSecond = record
    kind: (kA, kB, kC);
  end;

var
  a: TFirst;
  b: TSecond;
begin
  a.kind := TFirst.kB;
  b.kind := TSecond.kC;
  if Ord(a.kind) <> 1 then halt(1);
  if Ord(b.kind) <> 2 then halt(2);
end.
