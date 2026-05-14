program autofree_with_form_a_raise_inside_01;

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
    with autofree TTracker.Create do
      raise Exception.Create('mid');
  except
    on E: Exception do ;
  end;
end;

begin
  DoWork;
  // form-A (hidden holder) must clean up on the exception path too
  if not destroyed then halt(1);
end.
