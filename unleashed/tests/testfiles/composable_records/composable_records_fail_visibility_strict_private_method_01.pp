{ %FAIL }
program composable_records_fail_visibility_strict_private_method_01;

{$mode unleashed}

type
  TInternal = record
  strict private
    function GetIt: LongInt;
  end;

  TWrapper = record
    embed TInternal;
  end;

function TInternal.GetIt: LongInt;
begin
  Result := 42;
end;

var
  w: TWrapper;
  v: LongInt;
begin
  { same as the field case but for a method - strict private
    method must not auto-flatten through embed }
  v := w.GetIt;
end.
