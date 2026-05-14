program composable_records_visibility_public_01;

{$mode unleashed}

type
  TInternal = record
  public
    value: LongInt;
  end;

  TWrapper = record
    embed TInternal;
  end;

var
  w: TWrapper;
begin
  w.value := 42;
  if w.value <> 42 then halt(1);
end.
