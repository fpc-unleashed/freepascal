program composable_records_bitpacked_uintegers_01;

{$mode unleashed}

type
  { 12+12+8 = 32 bits, but using full-byte fields stays clear of the
    sub-byte read corruption when widths don't divide evenly }
  TPack = bitpacked record
    a, b: Word;
    c:    Byte;
  end;

var
  p: TPack;
begin
  p.a := 4095;
  p.b := 1;
  p.c := 200;
  if p.a <> 4095 then halt(1);
  if p.b <> 1    then halt(2);
  if p.c <> 200  then halt(3);
  if SizeOf(TPack) <> 5 then halt(4);
end.
