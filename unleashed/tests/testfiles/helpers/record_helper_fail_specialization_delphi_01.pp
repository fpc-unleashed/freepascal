{ %FAIL }
{ outside unleashed mode the helper extended type must not be a
  specialization spelled directly in the declaration }
program record_helper_fail_specialization_delphi_01;

{$mode delphi}

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
end.
