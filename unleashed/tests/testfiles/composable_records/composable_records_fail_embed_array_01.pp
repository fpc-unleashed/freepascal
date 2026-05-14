{ %FAIL }
program composable_records_fail_embed_array_01;

{$mode unleashed}

type
  TArr = array[0..3] of Byte;
  TRec = record
    embed TArr;       { array has no fields to flatten }
  end;
begin
end.
