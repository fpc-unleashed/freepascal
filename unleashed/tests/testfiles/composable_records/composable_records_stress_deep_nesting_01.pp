program composable_records_stress_deep_nesting_01;

{$mode unleashed}

type
  TLevel5 = record value: Integer; end;
  TLevel4 = record embed TLevel5; tag5: Byte; end;
  TLevel3 = record embed TLevel4; tag4: Byte; end;
  TLevel2 = record embed TLevel3; tag3: Byte; end;
  TLevel1 = record embed TLevel2; tag2: Byte; end;
  TTop = record embed TLevel1; tag1: Byte; end;

var
  t: TTop;
begin
  { 5-level embed chain - flatten reaches value through 5 carriers }
  t.value := 12345;
  t.tag5 := 5; t.tag4 := 4; t.tag3 := 3; t.tag2 := 2; t.tag1 := 1;
  if t.value <> 12345 then halt(1);
  if t.tag5 <> 5 then halt(2);
  if t.tag4 <> 4 then halt(3);
  if t.tag3 <> 3 then halt(4);
  if t.tag2 <> 2 then halt(5);
  if t.tag1 <> 1 then halt(6);
end.
