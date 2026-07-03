program parallelfor_method_self_33;
{$mode unleashed}
uses SysUtils;
// the body runs inside a class method: Self, instance fields and calls to
// other methods travel through the captured frame into the worker threads
type
  TAcc = class
    FBias: Integer;
    FTotal: Integer;
    function Step: Integer;
    procedure Run(n: Integer);
  end;

function TAcc.Step: Integer;
begin
  Result := FBias;
end;

procedure TAcc.Run(n: Integer);
begin
  for parallel var i := 1 to n do
  begin
    if Self.FBias <> 3 then halt(1);
    InterlockedExchangeAdd(FTotal, Step);
  end;
end;

var a: TAcc;
begin
  a := TAcc.Create;
  a.FBias := 3;
  a.Run(4000);
  if a.FTotal <> 12000 then halt(2);
  a.Free;
end.
