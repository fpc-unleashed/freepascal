program autofree_on_exception_path_01;

{$mode unleashed}

uses SysUtils;

type
  TTracker = class
    destructor Destroy; override;
  end;

var
  destroyed: Boolean = false;

destructor TTracker.Destroy;
begin
  destroyed := true;
  inherited;
end;

procedure DoWork;
begin
  var t := autofree TTracker.Create;
  raise Exception.Create('boom');
end;

begin
  try
    DoWork;
  except
  end;
  // autofree must have fired during stack unwinding
  if not destroyed then halt(1);
end.
