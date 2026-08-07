program prepostincdec_ansistring_elem_11;
{$mode unleashed}
var
  s, t: AnsiString;
begin
  s := 'hello';
  t := s;
  UniqueString(t);
  // element write makes s unique, t keeps its buffer
  if PostInc(s[1]) <> 'h' then halt(1);
  if s <> 'iello' then halt(2);
  if t <> 'hello' then halt(3);
  if PreInc(s[2]) <> 'f' then halt(4);
  if s <> 'ifllo' then halt(5);
end.
