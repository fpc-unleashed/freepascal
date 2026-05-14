program composable_records_union_with_inline_record_01;

{$mode unleashed}

type
  TRec = record
    union
      record
        x, y, z: LongInt;
      end;
      v: array[0..2] of LongInt;
    end;
  end;

var
  r: TRec;
begin
  r.x := 100;
  r.y := 200;
  r.z := 300;
  if r.v[0] <> 100 then halt(1);
  if r.v[1] <> 200 then halt(2);
  if r.v[2] <> 300 then halt(3);
end.
