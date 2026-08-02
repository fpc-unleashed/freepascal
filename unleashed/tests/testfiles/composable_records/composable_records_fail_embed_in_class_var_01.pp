{ %FAIL }
program composable_records_fail_embed_in_class_var_01;
{ embed merges instance fields, so a `class var` section must reject
  it instead of silently making the merged fields per-instance }

{$mode unleashed}

type
  TBar = record
    a, b : Byte;
  end;

  TFoo = record
    class var
      embed TBar;
  end;

begin
end.
