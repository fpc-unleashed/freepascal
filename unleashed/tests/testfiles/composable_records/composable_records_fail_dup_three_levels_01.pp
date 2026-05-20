{ %FAIL }
program composable_records_fail_dup_three_levels_01;

{$mode unleashed}

type
  TA = record x: Byte; end;
  TB = record embed TA; end;       { B brings 'x' through its own embed }
  TC = record
    embed TB;                       { brings 'x' transitively }
    x: Word;                        { collides with TB.TA.x }
  end;
begin
end.
