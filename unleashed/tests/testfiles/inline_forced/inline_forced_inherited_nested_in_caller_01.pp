program inline_forced_inherited_nested_in_caller_01;
{$mode unleashed}

// the inline-with-inherited method is itself expanded inside another
// routine, so the inline self must survive a second level of substitution

type
  TBase = class
    function Calc(x: longint): longint; virtual;
  end;
  TChild = class(TBase)
    function CalcTwice(x: longint): longint; inline;
  end;

function TBase.Calc(x: longint): longint; begin Result := x + 1; end;
function TChild.CalcTwice(x: longint): longint; begin Result := inherited Calc(x) * 2; end;

function use(c: TChild; x: longint): longint;
begin
  Result := c.CalcTwice(x) + c.CalcTwice(x + 1);
end;

var
  c: TChild;
begin
  c := TChild.Create;
  // CalcTwice(3)=8, CalcTwice(4)=10 -> 18
  if use(c, 3) <> 18 then Halt(1);
  c.Free;
end.
