{ %FAIL }

// for-step: non-ordinal step expression (string) must be rejected

program forstep_fail_non_ordinal_step_01;

{$mode unleashed}

var
  i : integer;
begin
  for i:=1 to 10 step 'abc' do
    writeln(i);
end.
