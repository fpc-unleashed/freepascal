program composable_records_generic_two_specializations_01;

{$mode unleashed}

type
  generic TBox<T> = record
    item: T;
    tag: Word;
  end;

  TBoxByte = specialize TBox<Byte>;
  TBoxLong = specialize TBox<LongWord>;

var
  bb: TBoxByte;
  bl: TBoxLong;
begin
  bb.item := 7;
  bb.tag := 1;
  bl.item := $11223344;
  bl.tag := 2;
  if bb.item <> 7 then halt(1);
  if bb.tag <> 1 then halt(2);
  if bl.item <> $11223344 then halt(3);
  if bl.tag <> 2 then halt(4);
  { sizes differ because T differs }
  if SizeOf(TBoxByte) >= SizeOf(TBoxLong) then halt(5);
end.
