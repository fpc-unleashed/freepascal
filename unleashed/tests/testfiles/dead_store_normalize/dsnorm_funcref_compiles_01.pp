{ %OPT="-O3 -Oodeadstore" }
{ Regression: normalize's "move the whole block out of the expression" branch
  used to crash the compiler (access violation) on function-reference /
  interface block-expressions -- the branch replaced a statement slot with a raw
  block node and then re-normalized a managed init/cleanup temp. It now declines
  to normalize such a procedure (dead-store elimination is simply skipped for
  it), so this must compile and run correctly. }
program dsnorm_funcref_compiles_01;
{$mode unleashed}
type
  TIntFn = reference to function(x: Integer): Integer;
function Inc1(x: Integer): Integer; begin Result := x + 1; end;
function Mul3(x: Integer): Integer; begin Result := x * 3; end;
var
  f, g, tmp: TIntFn;
begin
  f := @Inc1;
  g := @Mul3;
  if f(10) <> 11 then Halt(1);
  if g(10) <> 30 then Halt(2);
  tmp := f; f := g; g := tmp;
  if f(10) <> 30 then Halt(3);
  if g(10) <> 11 then Halt(4);
end.
