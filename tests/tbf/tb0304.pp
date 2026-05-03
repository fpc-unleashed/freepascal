{ %FAIL }

// for-step: non-ordinal step expression (string) must be rejected

program tb0304;

{$mode unleashed}

var
  i : integer;
begin
  for i:=1 to 10 step 'abc' do
    writeln(i);
end.
