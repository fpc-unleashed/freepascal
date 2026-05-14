{ %NORUN %CHECKBIN_HAS=TKeepRttiDistinctiveBox }
program striprtti_class_name_kept_without_modeswitch_01;
{$mode unleashed}

// no striprtti modeswitch -> RTTI keeps the distinctive type-name string
// in the binary; this test pins down the default behaviour
type
  TKeepRttiDistinctiveBox = class
    Value: Integer;
  end;

var
  inst: TKeepRttiDistinctiveBox;
begin
  inst := TKeepRttiDistinctiveBox.Create;
  inst.Value := 7;
  inst.Free;
end.
