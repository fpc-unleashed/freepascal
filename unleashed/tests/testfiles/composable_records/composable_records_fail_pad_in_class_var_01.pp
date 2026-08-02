{ %FAIL }
program composable_records_fail_pad_in_class_var_01;
{ pad reserves instance bits, so a `class var` section must reject it
  instead of silently padding the instance layout }

{$mode unleashed}

type
  TFoo = bitpacked record
    class var
      pad 4;
      x : 0..15;
  end;

begin
end.
