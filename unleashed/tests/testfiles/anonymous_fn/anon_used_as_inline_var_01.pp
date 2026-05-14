program anon_used_as_inline_var_01;

{$mode unleashed}

type
  TIntFn = reference to function(x: Integer): Integer;

begin
  var sq: TIntFn := function(x: Integer): Integer
                    begin
                      Result := x * x;
                    end;
  if sq(3)  <> 9   then halt(1);
  if sq(11) <> 121 then halt(2);
end.
