program autofree_with_loop_iter_inheritance_01;

{$mode unleashed}

type
  TBase = class
    destructor Destroy; override;
  end;

  TDerived = class(TBase)
  end;

var
  destroy_count: Integer = 0;

destructor TBase.Destroy;
begin
  Inc(destroy_count);
  inherited;
end;

begin
  for var i := 1 to 10 do
  begin
    var t := autofree TDerived.Create;
    if t = nil then halt(99);
  end;
  if destroy_count <> 10 then halt(1);
end.
