{ `future of string` written in another unit is the same type as one written here }
program asyncawait_crossunit_type_17;
{$mode unleashed}
uses asyncawait_crossunit_helper;
var f: future of string;
begin
  f := make;      // unit -> program
  take(f);        // program -> unit
  if await f <> 'xu' then halt(2);
end.
