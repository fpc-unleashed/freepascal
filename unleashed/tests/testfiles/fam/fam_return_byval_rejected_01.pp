{ %FAIL }

program fam_return_byval_rejected_01;

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
