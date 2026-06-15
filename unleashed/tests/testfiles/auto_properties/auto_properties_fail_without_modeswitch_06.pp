{ %FAIL }
program auto_properties_fail_without_modeswitch_06;

{$mode objfpc}

// without the modeswitch a bare property is rejected the classic way
type
  TFoo = class
    property X: Integer;
  end;

begin
end.
