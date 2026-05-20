program composable_records_inline_anon_packed_top_01;

{$mode unleashed}

type
  { inline anonymous `packed record` at top of a record body must parse
    in advanced records mode - regression for the parse_record_members
    case statement that previously only handled `_RECORD` }
  TRec = record
    packed record
      a, b, c: Byte;
    end;
    tail: LongInt;
  end;

var
  r: TRec;
begin
  r.a := 1;
  r.b := 2;
  r.c := 3;
  r.tail := 42;
  if r.a + r.b + r.c <> 6 then halt(1);
  if r.tail <> 42 then halt(2);
end.
