program lock_class_var_01;
{$mode unleashed}

type
  TWidget = class
  public
    class var SharedCount: Integer;
    class procedure Bump;
  end;

class procedure TWidget.Bump;
begin
  lock(SharedCount) do Inc(SharedCount);
end;

begin
  TWidget.SharedCount := 0;
  TWidget.Bump;
  TWidget.Bump;
  TWidget.Bump;
  if TWidget.SharedCount <> 3 then halt(1);
end.
