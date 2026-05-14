program composable_records_union_bitsize_01;

{$mode unleashed}

type
  TRec = packed record
    union of Byte bitsize 20
      a: bitpacked record
        x: 20;
      end;
      b: bitpacked record
        y: 16;
      end;
    end;
  end;

begin
  { bitsize 20 -> ceil(20/8) = 3 bytes }
  if SizeOf(TRec) <> 3 then halt(1);
end.
