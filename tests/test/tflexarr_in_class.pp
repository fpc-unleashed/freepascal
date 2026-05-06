{ %FAIL }

program tflexarr_in_class;

{ FAM is restricted to plain records, not allowed in class }

{$mode unleashed}

type
  TBad = class
    a: integer;
    data: array[] of byte;
  end;

begin
end.
