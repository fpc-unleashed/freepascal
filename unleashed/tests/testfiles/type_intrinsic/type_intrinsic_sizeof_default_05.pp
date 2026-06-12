program type_intrinsic_sizeof_default_05;

{$mode unleashed}

type
  TPoint = record x, y: Integer; end;

var
  x: Integer;
  d: Double;
  s: AnsiString;
  pt: TPoint;
  defi: Integer;
  defd: Double;
  defs: AnsiString;
  defp: TPoint;
begin
  if SizeOf(Type(x)) <> 4 then Halt(1);
  if SizeOf(Type(d)) <> 8 then Halt(2);
  if SizeOf(Type(pt)) <> 8 then Halt(3);

  defi := Default(Type(x));
  if defi <> 0 then Halt(4);

  defd := Default(Type(d));
  if defd <> 0.0 then Halt(5);

  defs := Default(Type(s));
  if defs <> '' then Halt(6);

  defp := Default(Type(pt));
  if (defp.x <> 0) or (defp.y <> 0) then Halt(7);
end.
