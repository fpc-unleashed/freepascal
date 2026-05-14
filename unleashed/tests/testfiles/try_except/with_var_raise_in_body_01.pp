program with_var_raise_in_body_01;

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
    with var t := autofree TTracker.Create do
    begin
      if t = nil then halt(99);
      raise Exception.Create('mid-with');
    end;
  except
    on E: Exception do
      ;
  end;
end;

begin
  DoWork;
  // exception thrown inside with-body must still trigger the autofree cleanup
  if not destroyed then halt(1);
end.
