program autofree_in_except_handler_01;

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

procedure Risky;
begin
  raise Exception.Create('boom');
end;

procedure DoWork;
begin
  try
    Risky;
  except
    on E: Exception do
    begin
      var t := autofree TTracker.Create;
      // t freed at end of this except handler
    end;
  end;
end;

begin
  DoWork;
  if not destroyed then halt(1);
end.
