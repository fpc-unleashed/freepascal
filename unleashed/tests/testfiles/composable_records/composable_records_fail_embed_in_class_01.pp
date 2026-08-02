{ %FAIL }
program composable_records_fail_embed_in_class_01;
{ embed is a record-only construct; in a class it must produce a
  dedicated error, not a generic syntax error }

{$mode unleashed}

type
  TBar = record
    a, b : Byte;
  end;

  TFoo = class
    embed TBar;
  end;

begin
end.
