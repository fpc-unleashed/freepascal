program composable_records_union_array_variant_01;

{$mode unleashed}

type
  TRec = record
    union
      asbytes: array[0..7] of Byte;
      asints:  array[0..1] of LongWord;
    end;
  end;

var
  r: TRec;
begin
  r.asints[0] := $11223344;
  r.asints[1] := $55667788;
  if r.asbytes[0] <> $44 then halt(1);
  if r.asbytes[4] <> $88 then halt(2);
  if r.asbytes[7] <> $55 then halt(3);
  if SizeOf(TRec) <> 8 then halt(4);
end.
