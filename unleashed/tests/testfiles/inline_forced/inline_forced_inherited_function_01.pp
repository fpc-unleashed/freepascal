program inline_forced_inherited_function_01;
{$mode unleashed}

// a inline (non-virtual) method calling inherited is expanded correctly:
// the self pointer in the inherited call is rewritten to the inline self

type
  TBase = class
    function Calc(x: longint): longint; virtual;
  end;
  TChild = class(TBase)
    function CalcInl(x: longint): longint; inline;
    function CalcCall(x: longint): longint;
  end;

function TBase.Calc(x: longint): longint; begin Result := x + 1; end;
function TChild.CalcInl(x: longint): longint; begin Result := inherited Calc(x) * 2; end;
function TChild.CalcCall(x: longint): longint; begin Result := inherited Calc(x) * 2; end;

var
  c: TChild;
  i: longint;
begin
  c := TChild.Create;
  for i := -5 to 5 do
    if c.CalcInl(i) <> c.CalcCall(i) then Halt(1);
  if c.CalcInl(5) <> 12 then Halt(2);
  c.Free;
end.
