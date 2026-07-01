{ %FAIL }
program lock_fail_field_01;
{$mode unleashed}

// instance fields would need a per-instance CS - v1 rejects them
type
  TFoo = class
    FCount: Integer;
    procedure Bump;
  end;

procedure TFoo.Bump;
begin
  lock(FCount) do Inc(FCount);
end;

begin
end.
