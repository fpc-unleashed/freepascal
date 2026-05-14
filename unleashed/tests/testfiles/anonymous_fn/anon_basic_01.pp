program anon_basic_01;

{$mode unleashed}

type
  TIntFn = function(x: Integer): Integer;

begin
  var add_one: TIntFn := function(x: Integer): Integer
                         begin
                           Result := x + 1;
                         end;
  if add_one(10) <> 11 then halt(1);
  if add_one(0)  <> 1  then halt(2);
end.
