program composable_records_bitpacked_mixed_forms_01;

{$mode unleashed}

type
  { mix regular field declarations with C-style `name: N` in the same
    bitpacked record body; per the doc this is legal }
  TBits = bitpacked record of Boolean
    full: Byte;            { regular byte field, 8 bits }
    flag: 1;               { C-style bit field, 1 bit }
    count: 1;
    big: Word;             { regular word field, 16 bits }
  end;

begin
  { 8 + 1 + 1 + 16 = 26 bits = ceil(26/8) = 4 bytes }
  if SizeOf(TBits) <> 4 then halt(1);
end.
