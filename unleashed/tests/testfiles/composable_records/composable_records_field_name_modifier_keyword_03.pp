program composable_records_field_name_modifier_keyword_03;
{ same-name field after a real pre-body modifier: `record align 4 size:
  Integer end;` - the `align 4` is the modifier (bumps record align to 4),
  the `size: Integer` is a regular field. parser must not get confused. }

{$mode unleashed}

type
  TAligned = record align 4
    size: Integer;
  end;

  TSizedAligned = record align 8 size 16
    bitalign: Integer;
    bitsize: Integer;
    align: Integer;
  end;

var
  a: TAligned;
  s: TSizedAligned;
begin
  a.size := 42;
  if a.size <> 42 then halt(1);
  if AlignOf(TAligned) < 4 then halt(2);
  s.align := 1; s.bitalign := 2; s.bitsize := 3;
  if (s.align <> 1) or (s.bitalign <> 2) or (s.bitsize <> 3) then halt(3);
  if SizeOf(TSizedAligned) <> 16 then halt(4);
  if AlignOf(TSizedAligned) < 8 then halt(5);
end.
