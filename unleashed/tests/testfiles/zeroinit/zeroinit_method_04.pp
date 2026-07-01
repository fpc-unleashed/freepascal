program zeroinit_method_04;

{$mode unleashed}

type
  TCalc = class
    function Sum: Integer; zeroinit;
  end;

function TCalc.Sum: Integer;
var
  a, b, c: Integer;
begin
  Inc(a, 10);
  Inc(b, 20);
  Inc(c, 30);
  Result := a + b + c;
end;

var
  obj: TCalc;
begin
  obj := TCalc.Create;
  try
    if obj.Sum <> 60 then halt(1);
    if obj.Sum <> 60 then halt(2);
  finally
    obj.Free;
  end;
end.
