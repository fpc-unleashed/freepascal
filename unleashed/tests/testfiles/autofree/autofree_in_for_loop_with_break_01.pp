program autofree_in_for_loop_with_break_01;

{$mode unleashed}

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

begin
  for var i := 1 to 100 do
  begin
    var t := autofree TTracker.Create;
    if i = 5 then break;
  end;
  // 5 iterations ran, 5 trackers created and destroyed (incl. break iter)
  if destroyed <> 5 then halt(1);
end.
