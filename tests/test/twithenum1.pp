{ test `with EnumType do` for scoped enums in mode unleashed }
{$mode unleashed}
{$scopedenums on}

type
  TColor = (red, green, blue);

var
  s: set of TColor;
  raw: byte;
begin
  with TColor do
    s := [red, blue];
  raw := pbyte(@s)^;
  if raw <> (1 shl 0) or (1 shl 2) then
    halt(1);

  { nested: outer enum, inner record - both scopes stacked }
  s := [];
  with TColor do
    begin
      s := [green];
    end;
  raw := pbyte(@s)^;
  if raw <> (1 shl 1) then
    halt(2);
end.
