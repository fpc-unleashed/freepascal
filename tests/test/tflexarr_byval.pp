{ %FAIL }

program tflexarr_byval;

{ a FAM-record cannot be passed as a value parameter }

{$mode unleashed}

type
  TFam = record
    code: integer;
    data: array[] of byte;
  end;

procedure bad(rec: TFam);
begin
end;

begin
end.
