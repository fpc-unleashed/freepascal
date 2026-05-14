program typehelper_array_01;

{$mode unleashed}
{$modeswitch typehelpers}

uses SysUtils;

type
  TIntArr = array of Integer;
  TIntArrHelper = type helper for TIntArr
    function Sum: Integer;
  end;

function TIntArrHelper.Sum: Integer;
begin
  Result := 0;
  for var x in Self do
    Result := Result + x;
end;

begin
  var arr: TIntArr := [1, 2, 3, 4, 5];
  if arr.Sum <> 15 then halt(1);
end.
