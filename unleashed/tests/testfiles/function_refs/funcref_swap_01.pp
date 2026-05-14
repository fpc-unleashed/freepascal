program funcref_swap_01;

{$mode unleashed}

type
  TIntFn = reference to function(x: Integer): Integer;

function Inc1(x: Integer): Integer; begin Result := x + 1; end;
function Mul3(x: Integer): Integer; begin Result := x * 3; end;

var
  f, g: TIntFn;

begin
  f := @Inc1;
  g := @Mul3;
  if f(10) <> 11 then halt(1);
  if g(10) <> 30 then halt(2);

  // swap two function refs
  var tmp := f;
  f := g;
  g := tmp;
  if f(10) <> 30 then halt(3);
  if g(10) <> 11 then halt(4);
end.
