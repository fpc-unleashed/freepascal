program composable_records_wild_union_overlay_struct_01;

{$mode unleashed}

type
  TRec = packed record
    union size 16
      asbytes: array[0..15] of Byte;
      record
        a, b: LongWord;
        c: array[0..7] of Byte;
      end;
    end;
  end;

var
  r: TRec;
begin
  r.a := $11223344;
  r.b := $55667788;
  if r.asbytes[0] <> $44 then halt(1);
  if r.asbytes[4] <> $88 then halt(2);
  if SizeOf(TRec) <> 16 then halt(3);
end.
