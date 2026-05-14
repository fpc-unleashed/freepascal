program autofree_constructor_raises_caught_01;

{$mode unleashed}

uses SysUtils;

type
  TBomb = class
    constructor Create;
    destructor Destroy; override;
  end;

var
  destroyed_count: Integer = 0;

constructor TBomb.Create;
begin
  raise Exception.Create('ctor-fails');
end;

destructor TBomb.Destroy;
begin
  Inc(destroyed_count);
  inherited;
end;

procedure DoWork;
begin
  var b := autofree TBomb.Create;
  halt(99);   // should never reach
end;

begin
  var caught := false;
  try
    DoWork;
  except
    on E: Exception do
      caught := true;
  end;
  if not caught then halt(1);
  // FPC auto-cleans the partially-constructed object exactly once;
  // autofree on the never-bound variable does NOT fire a second time
  if destroyed_count <> 1 then halt(2);
end.
