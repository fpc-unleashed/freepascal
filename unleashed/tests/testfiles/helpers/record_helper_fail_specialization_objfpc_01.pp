{ %FAIL }
{ outside unleashed mode the helper extended type must not be a
  specialization, `specialize` form included }
program record_helper_fail_specialization_objfpc_01;

{$mode objfpc}
{$modeswitch typehelpers}

type
  generic TWrap<T> = record
    val: T;
  end;

  TIntWrapHelper = type helper for specialize TWrap<LongInt>
    procedure bump;
  end;

procedure TIntWrapHelper.bump;
begin
  Inc(Self.val);
end;

begin
end.
