program composable_records_union_of_record_type_01;

{$mode unleashed}

type
  TVec = record
    x, y: LongInt;
  end;

  TRec = record
    union of TVec
      v: TVec;
      raw: array[0..1] of LongInt;
    end;
  end;

var
  r: TRec;
begin
  { `of TVec` makes size = SizeOf(TVec) = 8, align = AlignOf(TVec) = 4 }
  if SizeOf(TRec) <> 8 then halt(1);
  r.v.x := 100;
  r.v.y := 200;
  if r.raw[0] <> 100 then halt(2);
  if r.raw[1] <> 200 then halt(3);
end.
