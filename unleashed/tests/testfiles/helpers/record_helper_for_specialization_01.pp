program record_helper_for_specialization_01;

{$mode unleashed}

type
  TWrap<T> = record
    val: T;
  end;

  TIntWrapHelper = record helper for TWrap<LongInt>
    procedure bump;
  end;

procedure TIntWrapHelper.bump;
begin
  Inc(Self.val);
end;

begin
  var w: TWrap<LongInt>;
  w.val := 1;
  w.bump;
  if w.val <> 2 then halt(1);
end.
