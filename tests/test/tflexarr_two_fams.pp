{ %FAIL }

program tflexarr_two_fams;

{ a record cannot have two flexible array members }

{$mode unleashed}

type
  TBad = record
    a: integer;
    one: array[] of byte;
    two: array[] of word;
  end;

begin
end.
