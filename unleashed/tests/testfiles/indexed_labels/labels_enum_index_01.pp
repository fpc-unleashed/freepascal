program labels_enum_index_01;

{$mode unleashed}

type
  TMode = (mFast, mSlow, mIdle);

label
  handler[mFast..mIdle];

var
  result_v: Integer = 0;
  m: TMode;

begin
  m := mSlow;
  goto handler[m];

  handler[mFast]: result_v := 1; goto done;
  handler[mSlow]: result_v := 2; goto done;
  handler[mIdle]: result_v := 3;

done:
  if result_v <> 2 then halt(1);
end.
