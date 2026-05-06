{ %FAIL }

program tflexarr_bare_var;

{ a flexible array type alone, outside a record, cannot declare a variable }

{$mode unleashed}

var
  bad: array[] of byte;
begin
end.
