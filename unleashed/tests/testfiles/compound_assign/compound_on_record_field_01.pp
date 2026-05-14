program compound_on_record_field_01;

{$mode unleashed}

type
  TCounter = record
    n: Integer;
  end;

var
  c: TCounter;

begin
  c.n := 10;
  c.n += 5;
  if c.n <> 15 then halt(1);
  c.n *= 2;
  if c.n <> 30 then halt(2);
  c.n div= 6;
  if c.n <> 5 then halt(3);
end.
