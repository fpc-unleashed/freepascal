program autofree_constructor_raises_01;

{$mode unleashed}

uses SysUtils;

type
  TBoom = class
    constructor Create;
  end;

constructor TBoom.Create;
begin
  raise Exception.Create('boom');
end;

var
  caught: Boolean = false;

procedure DoWork;
begin
  // FPC auto-destroys on failed constructor; autofree on never-assigned
  // variable must NOT fire (no double-free)
  var b := autofree TBoom.Create;
  halt(99);
end;

begin
  try
    DoWork;
  except
    caught := true;
  end;
  if not caught then halt(1);
end.
