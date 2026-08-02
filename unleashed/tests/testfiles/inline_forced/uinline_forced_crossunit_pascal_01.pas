unit uinline_forced_crossunit_pascal_01;

{$mode unleashed}

interface

function XuAdd(a, b: Integer): Integer; inline;

implementation

function XuAdd(a, b: Integer): Integer;
begin
  Result := a + b;
end;

end.
