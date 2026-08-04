{ %FAIL }

program fam_not_last_field_rejected_02;

{ a flexible array member must be the last field of the record }

{$mode unleashed}

type
  TBad = record
    a: integer;
    data: array[] of byte;
    b: integer;
  end;

begin
end.
