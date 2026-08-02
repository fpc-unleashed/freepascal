program inline_forced_mutual_recursion_fallback_01;
{$mode unleashed}

// mutual recursion: the expansion is cut off at the depth limit (with a
// warning) and the remaining call is emitted as a regular call

type
  TFoo = class
    function IsEven(n: Integer): Boolean; inline;
    function IsOdd(n: Integer): Boolean; inline;
  end;

function TFoo.IsEven(n: Integer): Boolean;
begin
  if n = 0 then Result := True else Result := IsOdd(n - 1);
end;

function TFoo.IsOdd(n: Integer): Boolean;
begin
  if n = 0 then Result := False else Result := IsEven(n - 1);
end;

var
  f: TFoo;
begin
  f := TFoo.Create;
  if not f.IsEven(4) then Halt(1);
  if f.IsOdd(4) then Halt(2);
  if not f.IsOdd(7) then Halt(3);
  f.Free;
end.
