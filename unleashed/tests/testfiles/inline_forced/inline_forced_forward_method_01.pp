program inline_forced_forward_method_01;
{$mode unleashed}

// a method body defined after its caller is still inlined: the
// caller's code generation waits until the body has been parsed

type
  TFoo = class
    function Twice(x: Integer): Integer; inline;
    function CallsTwice(x: Integer): Integer;
  end;

function TFoo.CallsTwice(x: Integer): Integer;
begin
  Result := Twice(x) + 1;
end;

function TFoo.Twice(x: Integer): Integer;
begin
  Result := x * 2;
end;

var
  f: TFoo;
begin
  f := TFoo.Create;
  if f.CallsTwice(20) <> 41 then Halt(1);
  if f.CallsTwice(-5) <> -9 then Halt(2);
  f.Free;
end.
