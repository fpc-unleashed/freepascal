program composable_records_field_name_modifier_keyword_02;
{ same collision inside `union` bodies: a `union` block's pre-body
  modifier parser must let the first variant's field still be named
  `size` / `bitsize` / `align` / `bitalign`. }

{$mode unleashed}

type
  TU = record
    code: Byte;
    union
      size: Integer;
      bitsize: Integer;
    end;
  end;

  TU2 = record
    union
      align: Integer;
      bitalign: Integer;
    end;
  end;

var
  u: TU;
  v: TU2;
begin
  u.code := 1;
  u.size := 100;
  if u.size <> 100 then halt(1);
  u.bitsize := 200;
  if u.bitsize <> 200 then halt(2);
  v.align := 7;
  if v.align <> 7 then halt(3);
  v.bitalign := 9;
  if v.bitalign <> 9 then halt(4);
end.
