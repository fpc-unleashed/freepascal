{ %FAIL }

program fam_bare_type_var_rejected_01;

{ a flexible array type alone, outside a record, cannot declare a variable }

{$mode unleashed}

var
  bad: array[] of byte;
begin
end.
