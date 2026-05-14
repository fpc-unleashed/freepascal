program autofree_in_with_form_d_runtime_check_01;

{$mode unleashed}

uses Classes;

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
  with var t: TTracker := autofree TTracker.Create do
    if t = nil then halt(99);
end;

begin
  DoWork;
  if not destroyed then halt(1);
end.
