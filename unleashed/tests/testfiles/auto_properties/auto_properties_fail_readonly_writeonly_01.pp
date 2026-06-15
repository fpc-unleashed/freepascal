{ %FAIL }
program auto_properties_fail_readonly_writeonly_01;

{$mode unleashed}

type
  TFoo = class
    property X: Integer; readonly; writeonly;
  end;

begin
end.
