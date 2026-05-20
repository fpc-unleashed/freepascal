{ %FAIL }
program composable_records_fail_embed_class_01;

{$mode unleashed}

type
  TFoo = class
    a: Integer;
  end;
  TRec = record
    embed TFoo;       { class - would embed a pointer, not the fields }
  end;
begin
end.
