program composable_records_union_packed_bitpacked_mix_01;

{$mode unleashed}

type
  TRec = record
    union of Byte size 2
      raw: Word;
      packed record
        lo, hi: Byte;
      end;
      bitpacked record of Boolean
        b0, b1, b2, b3, b4, b5, b6, b7,
        b8, b9, ba, bb, bc, bd, be, bf: 1;
      end;
    end;
  end;

var
  r: TRec;
begin
  r.raw := $A55A;
  if r.lo <> $5A then halt(1);
  if r.hi <> $A5 then halt(2);
  if not r.b1 then halt(3);
  if SizeOf(TRec) <> 2 then halt(4);
end.
