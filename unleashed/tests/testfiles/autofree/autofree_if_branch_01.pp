program autofree_if_branch_01;

{$mode unleashed}

uses Classes;

type
  TTracker = class
    destructor Destroy; override;
  end;

var
  destroyed: Integer = 0;

destructor TTracker.Destroy;
begin
  Inc(destroyed);
  inherited;
end;

procedure DoWork(branch: Boolean);
begin
  if branch then
  begin
    var t := autofree TTracker.Create;
    // t freed at end of this `if` block
  end
  else
  begin
    var u := autofree TTracker.Create;
  end;
end;

begin
  DoWork(true);
  if destroyed <> 1 then halt(1);
  DoWork(false);
  if destroyed <> 2 then halt(2);
end.
