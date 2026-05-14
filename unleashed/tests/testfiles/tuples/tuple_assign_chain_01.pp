program tuple_assign_chain_01;

{$mode unleashed}

function GetTwo: (Integer, Integer);
begin
  Result := (3, 7);
end;

var
  a, b, c, d: Integer;

begin
  (a, b) := GetTwo;
  if a <> 3 then halt(1);
  if b <> 7 then halt(2);
  // chain via destructure of literal built from prior values
  (c, d) := (a + b, a * b);
  if c <> 10 then halt(3);
  if d <> 21 then halt(4);
end.
