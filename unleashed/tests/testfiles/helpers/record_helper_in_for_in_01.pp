program record_helper_in_for_in_01;

{$mode unleashed}

type
  TPair = record
    a, b: Integer;
  end;

  TPairHelper = record helper for TPair
    function Total: Integer;
  end;

function TPairHelper.Total: Integer;
begin
  Result := Self.a + Self.b;
end;

begin
  var pairs: array of TPair;
  SetLength(pairs, 3);
  pairs[0].a := 1; pairs[0].b := 2;
  pairs[1].a := 10; pairs[1].b := 20;
  pairs[2].a := 100; pairs[2].b := 200;

  var sum := 0;
  for var p in pairs do
    sum := sum + p.Total;
  if sum <> 333 then halt(1);
end.
