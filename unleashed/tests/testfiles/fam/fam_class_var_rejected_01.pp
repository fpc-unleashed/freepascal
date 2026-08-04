{ %FAIL }

program fam_class_var_rejected_01;

{ FAM cannot be a class var inside a record (no static allocation possible) }

{$mode unleashed}

type
  TBad = record
    a: integer;
    class var data: array[] of byte;
  end;

begin
end.
