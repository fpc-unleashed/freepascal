{ %OPT=-CR }
program composable_records_range_check_within_bounds_01;
{ within-bounds assignment must NOT trip range check with -CR active.
  pairs with the %FAIL out-of-range test. }

{$mode unleashed}

type
  TInner = record
    pct: 0..100;
  end;
  TOuter = record
    embed TInner;
  end;

var
  o: TOuter;
  x: Integer;
begin
  x := 50;
  o.pct := x;
  if o.pct <> 50 then halt(1);
end.
