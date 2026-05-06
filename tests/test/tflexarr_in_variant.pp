{ %FAIL }

program tflexarr_in_variant;

{ FAM is not allowed inside a variant part of a record }

{$mode unleashed}

type
  TBad = record
    tag: integer;
    case integer of
      0: (i: integer);
      1: (data: array[] of byte);
  end;

begin
end.
