{ %FAIL }
program inline_forced_fail_virtual_01;
{$mode unleashed}

type
  TFoo = class
    function Calc(x: Integer): Integer; virtual; inline;
  end;

function TFoo.Calc(x: Integer): Integer;
begin
  Result := x + 1;
end;

var
  f: TFoo;
begin
  f := TFoo.Create;
  writeln(f.Calc(1));
  f.Free;
end.
