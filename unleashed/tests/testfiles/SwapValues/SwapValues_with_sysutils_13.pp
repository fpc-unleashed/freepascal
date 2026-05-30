program SwapValues_with_sysutils_13;
{$mode unleashed}
// SwapValues is a fresh name, so it works even alongside SysUtils (which ships its
// own generic Swap<T> / Exchange<T>) with no conflict
uses
  SysUtils;
var
  a, b: Integer;
  s, t: AnsiString;
begin
  a := 10; b := 20;
  SwapValues(a, b);
  if (a <> 20) or (b <> 10) then halt(1);
  s := 'aa'; t := 'bb';
  SwapValues(s, t);
  if (s <> 'bb') or (t <> 'aa') then halt(2);
end.
