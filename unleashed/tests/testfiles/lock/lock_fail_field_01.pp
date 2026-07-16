{ %FAIL }
program lock_fail_field_01;
{$mode unleashed}

// an auto target's hidden CS is keyed by symbol, not instance - a plain
// field is rejected (an explicit TRTLCriticalSection field is fine)
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
