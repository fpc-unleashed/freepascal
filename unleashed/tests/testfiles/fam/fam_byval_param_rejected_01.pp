{ %FAIL }

program fam_byval_param_rejected_01;

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
