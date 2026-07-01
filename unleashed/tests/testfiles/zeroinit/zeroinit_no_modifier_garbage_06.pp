{ %NORUN }
program zeroinit_no_modifier_garbage_06;

{$mode unleashed}

// without zeroinit a plain Integer local has indeterminate stack content;
// this test only verifies that omitting the modifier still compiles cleanly
procedure NoZeroInit;
var
  i: Integer;
begin
  i := 42;
  if i <> 42 then halt(1);
end;

begin
  NoZeroInit;
end.
