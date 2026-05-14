program anon_passed_as_arg_01;

{$mode unleashed}

type
  TBinOp = reference to function(a, b: Integer): Integer;

function Reduce(arr: array of Integer; op: TBinOp; init: Integer): Integer;
begin
  Result := init;
  for var x in arr do
    Result := op(Result, x);
end;

begin
  var sum := Reduce([1, 2, 3, 4, 5],
                    function(a, b: Integer): Integer
                    begin
                      Result := a + b;
                    end, 0);
  if sum <> 15 then halt(1);

  var max := Reduce([3, 1, 4, 1, 5, 9, 2, 6],
                    function(a, b: Integer): Integer
                    begin
                      if b > a then Result := b else Result := a;
                    end, Low(Integer));
  if max <> 9 then halt(2);
end.
