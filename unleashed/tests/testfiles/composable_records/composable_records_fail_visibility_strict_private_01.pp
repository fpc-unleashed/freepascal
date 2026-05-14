{ %FAIL }
program composable_records_fail_visibility_strict_private_01;

{$mode unleashed}

type
  TInternal = record
  strict private
    secret: LongInt;
  end;

  TWrapper = record
    embed TInternal;
  end;

var
  w: TWrapper;
begin
  { strict private is scoped to TInternal itself; reaching it via
    the flat path from outside TInternal must be a compile error
    even from the same unit }
  w.secret := 42;
end.
