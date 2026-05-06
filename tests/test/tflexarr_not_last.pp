{ %FAIL }

program tflexarr_not_last;

{ a flexible array member must be the last field of the record }

{$mode unleashed}

type
  TBad = record
    a: integer;
    data: array[] of byte;
    b: integer;
  end;

begin
end.
