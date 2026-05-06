{ %FAIL }

program tflexarr_two_in_batch;

{ a single declaration batch cannot create two FAMs in one record }

{$mode unleashed}

type
  TBad = record
    a: integer;
    one, two: array[] of byte;
  end;

begin
end.
