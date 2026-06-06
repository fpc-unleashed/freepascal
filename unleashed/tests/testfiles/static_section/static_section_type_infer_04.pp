program static_section_type_infer_04;
{$mode unleashed}

procedure Check;
static
  ord_val := 10;          // bare integer -> LongInt (Int32)
  str_val := 'hello';     // string literal -> string
  char_val := 'X';        // single char -> string (promoted like inline var)
  float_val := 3.14;      // float literal
begin
  if SizeOf(ord_val) <> SizeOf(LongInt) then halt(1);
  if str_val <> 'hello' then halt(2);
  if char_val <> 'X' then halt(3);
  if float_val < 3.13 then halt(4);
  if float_val > 3.15 then halt(4);
end;

begin
  Check;
end.
