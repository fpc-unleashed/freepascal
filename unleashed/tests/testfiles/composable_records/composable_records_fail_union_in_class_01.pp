{ %FAIL }
program composable_records_fail_union_in_class_01;
{ union is a record-only construct; in a class it must produce a
  dedicated error, not a generic syntax error }

{$mode unleashed}

type
  TFoo = class
    union raw : DWord; packed record lo, mid, hi : Byte; end; end;
  end;

begin
end.
