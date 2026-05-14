{ %FAIL }
program composable_records_fail_record_of_T_plain_01;

{$mode unleashed}

type
  TRec = record of Byte    { plain record cannot carry a default type }
    a: 1;
  end;
begin
end.
