program strinterp_in_generic_01;

{$mode unleashed}

// literal fragments must survive the generic token record/replay cycle

function describe<T>(x: T): string;
begin
  result := $'value is {x} indeed';
end;

function pair<T>(a, b: T): string;
begin
  result := $'a={a}, b={b}.';
end;

begin
  if describe<integer>(42) <> 'value is 42 indeed' then halt(1);
  if describe<string>('foo') <> 'value is foo indeed' then halt(2);
  if pair<integer>(1, 2) <> 'a=1, b=2.' then halt(3);
end.
