program inline_forced_forward_transitive_01;
{$mode unleashed}

// deferral is transitive: the first body inlines the second, which in turn
// inlines the third; all bodies come after the outermost caller

type
  TFoo = class
    function Level1(x: Integer): Integer;
    function Level2(x: Integer): Integer; inline;
    function Level3(x: Integer): Integer; inline;
  end;

function TFoo.Level1(x: Integer): Integer;
begin
  Result := Level2(x) + 100;
end;

function TFoo.Level2(x: Integer): Integer;
begin
  Result := Level3(x) + 10;
end;

function TFoo.Level3(x: Integer): Integer;
begin
  Result := x + 1;
end;

var
  f: TFoo;
begin
  f := TFoo.Create;
  if f.Level1(1) <> 112 then Halt(1);
  if f.Level1(0) <> 111 then Halt(2);
  f.Free;
end.
