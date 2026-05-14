program anon_capture_param_01;

{$mode unleashed}

type
  TIntFn = reference to function(x: Integer): Integer;

function MakeAdder(delta: Integer): TIntFn;
begin
  Result := function(x: Integer): Integer
            begin
              Result := x + delta;
            end;
end;

begin
  var add5  := MakeAdder(5);
  var add10 := MakeAdder(10);
  if add5(3)   <> 8  then halt(1);
  if add10(3)  <> 13 then halt(2);
  if add5(100) <> 105 then halt(3);
end.
