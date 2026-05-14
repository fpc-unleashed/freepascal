program record_helper_self_modify_01;

{$mode unleashed}

type
  TCounter = record
    n: Integer;
  end;

  TCounterHelper = record helper for TCounter
    procedure Bump;
    procedure Reset;
  end;

procedure TCounterHelper.Bump;
begin
  Inc(Self.n);
end;

procedure TCounterHelper.Reset;
begin
  Self.n := 0;
end;

var
  c: TCounter;

begin
  c.n := 0;
  c.Bump; c.Bump; c.Bump;
  if c.n <> 3 then halt(1);
  c.Reset;
  if c.n <> 0 then halt(2);
end.
