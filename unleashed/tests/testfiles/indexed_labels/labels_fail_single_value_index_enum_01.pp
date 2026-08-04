{ %FAIL }
program labels_fail_single_value_index_enum_01;

{$mode unleashed}

{ a single enum value follows the same rule as a single integer - use
  foo[mFast..mFast], a value list or the whole enum type }

type
  TMode = (mFast, mSlow, mIdle);

label foo[mFast];

begin
  foo[mFast]: writeln('unreachable');
end.
