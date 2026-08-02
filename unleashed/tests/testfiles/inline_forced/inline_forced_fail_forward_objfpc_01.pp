{ %FAIL }
program inline_forced_fail_forward_objfpc_01;
{$mode objfpc}

// outside unleashed mode the forward directive still conflicts with inline

function Add5(x: Integer): Integer; inline; forward;

function Add5(x: Integer): Integer;
begin
  Result := x + 5;
end;

begin
  if Add5(1) <> 6 then Halt(1);
end.
