program composable_records_wild_innermost_wins_override_01;

{$mode unleashed}

type
  { outer default = Byte, inner default = Word - inner overrides for its
    body, outer comes back after the inner closes }
  TRec = packed record
    union of Byte size 4
      a: bitpacked record           { inherits Byte }
        flag: 1;                    { Byte bitsize 1 }
        inner: bitpacked record of Word     { override: Word }
          x: 4;                     { Word bitsize 4 }
        end;
        tail: 1;                    { back to Byte bitsize 1 }
      end;
      b: bitpacked record
        whole: 4;                   { inherits Byte }
      end;
    end;
  end;

begin
  { size 4 forced by `union of Byte size 4` }
  if SizeOf(TRec) <> 4 then halt(1);
end.
