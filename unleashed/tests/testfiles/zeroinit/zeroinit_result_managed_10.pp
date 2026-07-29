{ %OPT=-Sew }
program zeroinit_result_managed_10;

{$mode unleashed}

// -Sew: any uninitialized-result warning fails the compile

function foo: string; zeroinit;
begin
  result += 'x';
end;

function bar: integer; zeroinit;
begin
  result += 7;
end;

var
  s: string;
begin
  // the caller-side buffer may alias the destination; zeroinit must
  // clear the stale value before the body runs
  s := 'stale';
  s := foo;
  if s <> 'x' then halt(1);
  if foo <> 'x' then halt(2);
  if bar <> 7 then halt(3);
end.
