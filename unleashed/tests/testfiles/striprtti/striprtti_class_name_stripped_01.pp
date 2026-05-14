{ %NORUN %CHECKBIN_LACKS=TStripRttiDistinctiveBox }
program striprtti_class_name_stripped_01;
{$mode unleashed}
{$modeswitch striprtti}

// striprtti modeswitch removes the type-name string from RTTI/VMT;
// the distinctive class name must NOT survive in the produced binary
type
  TStripRttiDistinctiveBox = class
    Value: Integer;
  end;

var
  inst: TStripRttiDistinctiveBox;
begin
  inst := TStripRttiDistinctiveBox.Create;
  inst.Value := 7;
  inst.Free;
end.
