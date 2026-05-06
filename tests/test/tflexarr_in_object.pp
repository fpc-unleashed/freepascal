{ %FAIL }

program tflexarr_in_object;

{ FAM is restricted to plain records, not allowed in object }

{$mode unleashed}

type
  TBad = object
    a: integer;
    data: array[] of byte;
  end;

begin
end.
