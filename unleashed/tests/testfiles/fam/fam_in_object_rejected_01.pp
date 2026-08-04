{ %FAIL }

program fam_in_object_rejected_01;

{ FAM is restricted to plain records, not allowed in object }

{$mode unleashed}

type
  TBad = object
    a: integer;
    data: array[] of byte;
  end;

begin
end.
