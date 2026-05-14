program funcref_basic_01;

{$mode unleashed}

type
  TIntFn = reference to function(x: Integer): Integer;

function Doubler(x: Integer): Integer;
begin
  Result := x * 2;
end;

function Negate(x: Integer): Integer;
begin
  Result := -x;
end;

begin
  var f: TIntFn := @Doubler;
  if f(5) <> 10 then halt(1);
  f := @Negate;
  if f(5) <> -5 then halt(2);
end.
