{ %FAIL }

program tflexarr_array_of;

{ a FAM-record cannot be the element type of an array }

{$mode unleashed}

type
  TFam = record
    code: integer;
    data: array[] of byte;
  end;

  TArr = array[0..3] of TFam;

begin
end.
