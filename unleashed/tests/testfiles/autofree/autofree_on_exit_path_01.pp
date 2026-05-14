program autofree_on_exit_path_01;

{$mode unleashed}

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

procedure DoWork(early: Boolean);
begin
  var t := autofree TTracker.Create;
  if early then Exit;
  // never reached when early=true
end;

begin
  DoWork(true);
  // autofree must have fired even on the early exit path
  if not destroyed then halt(1);
end.
