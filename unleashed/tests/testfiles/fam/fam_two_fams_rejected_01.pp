{ %FAIL }

program fam_two_fams_rejected_01;

{ a record cannot have two flexible array members }

{$mode unleashed}

type
  TBad = record
    a: integer;
    one: array[] of byte;
    two: array[] of word;
  end;

begin
end.
