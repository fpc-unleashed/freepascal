program autofree_in_loop_iteration_01;

{$mode unleashed}

type
  TTracker = class
    destructor Destroy; override;
  end;

var
  destroy_count: Integer = 0;

destructor TTracker.Destroy;
begin
  Inc(destroy_count);
  inherited;
end;

begin
  for var i := 1 to 5 do
  begin
    var t := autofree TTracker.Create;
    // each iteration body is a scope, autofree fires per iteration
  end;
  if destroy_count <> 5 then halt(1);
end.
