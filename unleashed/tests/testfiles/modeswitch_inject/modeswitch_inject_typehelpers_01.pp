program modeswitch_inject_typehelpers_01;

{$mode unleashed}
{$modeswitch typehelpers}

// without {$modeswitch typehelpers}, the type helper for Integer is rejected
type
  TIntHelper = type helper for Integer
    function Triple: Integer;
  end;

function TIntHelper.Triple: Integer;
begin
  Result := Self * 3;
end;

var
  n: Integer;
begin
  n := Integer(5).Triple;
  if n <> 15 then Halt(1);
end.
