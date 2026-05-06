{ %FAIL }

program tflexarr_local;

{ a FAM-record variable cannot be allocated on the stack }

{$mode unleashed}

type
  TFam = record
    code: integer;
    data: array[] of byte;
  end;

var
  bad: TFam;
begin
end.
