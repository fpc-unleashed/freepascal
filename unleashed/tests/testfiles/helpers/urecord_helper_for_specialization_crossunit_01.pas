unit urecord_helper_for_specialization_crossunit_01;

{$mode unleashed}

interface

type
  TWrap<T> = record
    val: T;
  end;

  TIntWrapHelper = record helper for TWrap<LongInt>
    procedure bump;
  end;

implementation

procedure TIntWrapHelper.bump;
begin
  Inc(Self.val);
end;

end.
