program embedbytes_inline_in_call_02;
{$mode unleashed}

// 1-arg $embedbytes is a bare array-of-byte literal usable as an argument
function SumBytes(a: array of byte): longint;
var
  i: integer;
begin
  Result := 0;
  for i := 0 to length(a) - 1 do
    Result := Result + a[i];
end;

begin
  if SumBytes({$embedbytes 'embedbytes_inline_in_call_02.pp'}) <= 0 then halt(1);
end.
