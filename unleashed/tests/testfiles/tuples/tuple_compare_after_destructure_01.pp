program tuple_compare_after_destructure_01;

{$mode unleashed}

function GetA: (Integer, Integer);  begin Result := (1, 2); end;
function GetB: (Integer, Integer);  begin Result := (1, 2); end;
function GetC: (Integer, Integer);  begin Result := (1, 3); end;

begin
  if GetA <>  GetB then halt(1);
  if GetA  =  GetC then halt(2);

  var (a, b) := GetA;
  var (c, d) := GetB;
  if (a, b)  <> (c, d) then halt(3);
end.
