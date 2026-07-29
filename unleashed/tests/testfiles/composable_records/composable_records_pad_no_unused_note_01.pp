{ %OPT="-vn -Sen" }
program composable_records_pad_no_unused_note_01;

{$mode unleashed}

{ the compiler-generated pad carrier field is internal padding and must
  not trigger a "private field never used" note; -Sen turns any note
  into a compile failure }

type
  TFlags = bitpacked record of Byte
    ready: 1;
    dirty: 1;
    pad 4;
    level: 2;
  end;

var
  f: TFlags;
begin
  f.ready := 1;
  f.level := 3;
  if f.ready <> 1 then halt(1);
  if f.level <> 3 then halt(2);
end.
