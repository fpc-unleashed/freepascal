program composable_records_union_bitpacked_variant_01;

{$mode unleashed}

type
  TRec = packed record
    union of Byte size 1
      raw: Byte;
      bits: bitpacked record of Boolean
        b0, b1, b2, b3, b4, b5, b6, b7: 1;
      end;
    end;
  end;

var
  r: TRec;
begin
  r.raw := $A5;       { 1010 0101 }
  if not r.bits.b0 then halt(1);
  if     r.bits.b1 then halt(2);
  if not r.bits.b2 then halt(3);
  if     r.bits.b3 then halt(4);
  if     r.bits.b4 then halt(5);
  if not r.bits.b5 then halt(6);
  if     r.bits.b6 then halt(7);
  if not r.bits.b7 then halt(8);
end.
