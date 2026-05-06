{ %FAIL }

program tflexarr_class_var;

{ FAM cannot be a class var inside a record (no static allocation possible) }

{$mode unleashed}

type
  TBad = record
    a: integer;
    class var data: array[] of byte;
  end;

begin
end.
