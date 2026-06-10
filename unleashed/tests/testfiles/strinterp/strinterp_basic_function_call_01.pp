program strinterp_basic_function_call_01;

{$mode unleashed}

function greet(const s: string): string;
begin
  result := 'hi ' + s;
end;

var
  name: string;
  s: string;
begin
  name := 'World';
  s := $'>> {greet(name)} <<';
  if s <> '>> hi World <<' then halt(1);

  s := $'len={Length(name)}';
  if s <> 'len=5' then halt(2);
end.
