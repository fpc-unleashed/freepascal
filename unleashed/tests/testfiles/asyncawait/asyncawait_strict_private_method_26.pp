program asyncawait_strict_private_method_26;
{$mode unleashed}

// `async <call>` on a strict private method of the own class
uses
  SysUtils;

type
  TFoo = class
  strict private
    n: Integer;
    procedure Worker;
    function Doubled(x: Integer): Integer;
  public
    procedure Go;
    function Snapshot: Integer;
  end;

procedure TFoo.Worker;
begin
  n := n + 3;
end;

function TFoo.Doubled(x: Integer): Integer;
begin
  result := 2 * x;
end;

procedure TFoo.Go;
begin
  var f := async Worker;
  await f;
  var g := async Doubled(10);
  n := n + await g;
end;

function TFoo.Snapshot: Integer;
begin
  result := n;
end;

var
  a: TFoo;
begin
  a := TFoo.Create;
  a.Go;
  if a.Snapshot <> 23 then halt(1);
  a.Free;
end.
