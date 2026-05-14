program autofree_chain_with_failure_recovery_01;

{$mode unleashed}

uses SysUtils;

type
  TTracker = class
    Tag: String;
    constructor Create(const ATag: String);
    destructor Destroy; override;
  end;

var
  trace: String = '';

constructor TTracker.Create(const ATag: String);
begin
  Tag := ATag;
end;

destructor TTracker.Destroy;
begin
  trace := trace + 'D' + Tag + ';';
  inherited;
end;

procedure DoWork;
begin
  var a := autofree TTracker.Create('A');
  var b := autofree TTracker.Create('B');
  raise Exception.Create('boom');
end;

begin
  try
    DoWork;
  except
  end;
  // even on exception, both autofrees fire in LIFO order
  if trace <> 'DB;DA;' then halt(1);
end.
