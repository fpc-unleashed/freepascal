program inline_static_in_with_try_01;
// inline static in a try body nested under with keeps its value across calls

{$mode unleashed}

var
  r: record
    a: integer;
  end;

function bump: integer;
begin
  result := 0;
  with r do try
    static s := 10;
    s := s+a;
    result := s;
  except
    halt(1);
  end;
end;

begin
  r.a := 1;
  if bump <> 11 then halt(2);
  if bump <> 12 then halt(3);
end.
