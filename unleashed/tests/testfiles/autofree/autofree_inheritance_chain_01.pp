program autofree_inheritance_chain_01;

{$mode unleashed}

type
  TBase = class
    destructor Destroy; override;
  end;

  TChild = class(TBase)
    destructor Destroy; override;
  end;

var
  trace: String = '';

destructor TBase.Destroy;
begin
  trace := trace + 'Base;';
  inherited;
end;

destructor TChild.Destroy;
begin
  trace := trace + 'Child;';
  inherited;
end;

procedure DoWork;
var
  c: TBase;
begin
  c := autofree TChild.Create;
  if c = nil then halt(99);
end;

begin
  DoWork;
  // Child first (most-derived destructor runs first), then Base via inherited
  if trace <> 'Child;Base;' then halt(1);
end.
