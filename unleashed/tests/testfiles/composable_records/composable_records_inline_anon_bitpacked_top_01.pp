program composable_records_inline_anon_bitpacked_top_01;

{$mode unleashed}

type
  { inline anonymous `bitpacked record` at top of a record body must parse
    in advanced records mode - same regression as the `packed record` case }
  TRec = record
    bitpacked record of Boolean
      x, y, z: 1;
    end;
    counter: LongInt;
  end;

var
  r: TRec;
begin
  r.x := True;
  r.z := True;
  r.counter := 7;
  if not r.x then halt(1);
  if     r.y then halt(2);
  if not r.z then halt(3);
  if r.counter <> 7 then halt(4);
end.
