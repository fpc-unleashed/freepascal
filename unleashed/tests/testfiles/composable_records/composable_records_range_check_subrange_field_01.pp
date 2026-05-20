{ %OPT=-Cr }
program composable_records_range_check_subrange_field_01;
{ -Cr enables runtime range checks; assigning out-of-range to a
  subrange field through embed must raise ERangeError. proves the
  flatten path does not bypass range enforcement. }

{$mode unleashed}

uses SysUtils;

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
  x := 200;
  try
    o.pct := x;
    halt(1);
  except
    on e: ERangeError do
      ; { expected }
    on e: Exception do
      halt(2);
  end;
end.
