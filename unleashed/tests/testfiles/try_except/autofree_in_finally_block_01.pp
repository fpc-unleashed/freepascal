program autofree_in_finally_block_01;

{$mode unleashed}

uses Classes, SysUtils;

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
  try
    raise Exception.Create('boom');
  except
    on E: Exception do
      ;
  end;

  // a separate try-finally block, autofree inside finally
  var control := 0;
  try
    Inc(control);
  finally
    var t := autofree TTracker.Create;
    if t = nil then halt(99);
  end;
  if control <> 1 then halt(2);
end;

begin
  DoWork;
  if not destroyed then halt(1);
end.
