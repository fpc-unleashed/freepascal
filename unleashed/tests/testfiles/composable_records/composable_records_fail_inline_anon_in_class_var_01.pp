{ %FAIL }
program composable_records_fail_inline_anon_in_class_var_01;
{ an inline anonymous record merges instance fields, so a `class var`
  section must reject it instead of making the fields per-instance }

{$mode unleashed}

type
  TFoo = record
    class var
      record
        a, b : Byte;
      end;
  end;

begin
end.
