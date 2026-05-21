program composable_records_field_name_modifier_keyword_01;
{ field names `size`, `bitsize`, `align`, `bitalign` collide with the
  pre-body modifier keywords. composable records keeps them as plain
  identifiers when the next token is `:` / `,` / `;` (stock FPC accepts
  records with these names; the pre-body modifier parser must not steal
  them). }

{$mode unleashed}

type
  TWithSize = record
    size: Integer;
  end;
  TWithBitSize = record
    bitsize: Integer;
  end;
  TWithAlign = record
    align: Integer;
  end;
  TWithBitAlign = record
    bitalign: Integer;
  end;
  TAllFour = record
    size, bitsize: Integer;
    align, bitalign: Integer;
  end;

var
  a: TWithSize;
  b: TWithBitSize;
  c: TWithAlign;
  d: TWithBitAlign;
  e: TAllFour;
begin
  a.size := 1;
  b.bitsize := 2;
  c.align := 3;
  d.bitalign := 4;
  e.size := 10; e.bitsize := 20;
  e.align := 30; e.bitalign := 40;
  if a.size <> 1 then halt(1);
  if b.bitsize <> 2 then halt(2);
  if c.align <> 3 then halt(3);
  if d.bitalign <> 4 then halt(4);
  if (e.size <> 10) or (e.bitsize <> 20) or
     (e.align <> 30) or (e.bitalign <> 40) then halt(5);
end.
