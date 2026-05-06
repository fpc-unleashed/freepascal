{ %FAIL }

program tflexarr_return;

{ a function cannot return a FAM-record by value }

{$mode unleashed}

type
  TFam = record
    code: integer;
    data: array[] of byte;
  end;

function bad: TFam;
begin
end;

begin
end.
