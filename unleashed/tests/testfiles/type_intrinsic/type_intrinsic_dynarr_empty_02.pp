program type_intrinsic_dynarr_empty_02;

{$mode unleashed}
{$R+}

var
  a: array of Integer;
begin
  // operand is NOT evaluated; touching a[0] on an empty dyn array must not
  // crash, raise range-check, or generate any runtime access
  WriteLn(High(Type(a[0])));
  WriteLn(Low(Type(a[0])));
  if High(Type(a[0])) <> 2147483647 then Halt(1);
  if Low(Type(a[0])) <> -2147483648 then Halt(2);
end.
