{ %FAIL }

program fam_batch_decl_rejected_01;

{ a single declaration batch cannot create two FAMs in one record }

{$mode unleashed}

type
  TBad = record
    a: integer;
    one, two: array[] of byte;
  end;

begin
end.
