{ %FAIL }
program composable_records_fail_dup_two_embeds_01;

{$mode unleashed}

type
  TA = record x: Byte; end;
  TB = record x: Word; end;
  TRec = record
    embed TA;
    embed TB;          { both contribute 'x' -> collision }
  end;
begin
end.
