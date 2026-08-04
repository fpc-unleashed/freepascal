{ %FAIL }

program fam_only_field_rejected_02;

{ a record with a FAM must have at least one other field before it }

{$mode unleashed}

type
  TBad = record
    data: array[] of byte;
  end;

begin
end.
