program asyncawait_strict_private_field_25;
{$mode unleashed}

// an async block inside a method sees strict private fields and Self
uses
  SysUtils;

type
  TFoo = class
  strict private
    hidden: Integer;
  public
    procedure Go;
    function Snapshot: Integer;
  end;

procedure TFoo.Go;
begin
  var f := async begin hidden := 5; end;
  await f;
  var g := async begin Self.hidden := Self.hidden + 2; end;
  await g;
end;

function TFoo.Snapshot: Integer;
begin
  result := hidden;
end;

var
  a, b: TFoo;
begin
  a := TFoo.Create;
  b := TFoo.Create;
  a.Go;
  b.Go;
  if a.Snapshot <> 7 then halt(1);
  if b.Snapshot <> 7 then halt(2);
  a.Free;
  b.Free;
end.
