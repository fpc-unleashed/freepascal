program typehelper_enum_01;

{$mode unleashed}
{$modeswitch typehelpers}

type
  TPriority = (pLow, pMid, pHigh);

  TPriorityHelper = type helper for TPriority
    function Score: Integer;
  end;

function TPriorityHelper.Score: Integer;
begin
  case Self of
    pLow:  Result := 1;
    pMid:  Result := 5;
    pHigh: Result := 10;
  end;
end;

var
  p: TPriority = pMid;

begin
  if p.Score        <> 5  then halt(1);
  if pLow.Score     <> 1  then halt(2);
  if pHigh.Score    <> 10 then halt(3);
end.
