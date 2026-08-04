{ %FAIL }

program fam_array_element_rejected_01;

{ a FAM-record cannot be the element type of an array }

{$mode unleashed}

type
  TFam = record
    code: integer;
    data: array[] of byte;
  end;

  TArr = array[0..3] of TFam;

begin
end.
