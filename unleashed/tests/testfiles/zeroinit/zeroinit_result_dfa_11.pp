{ %OPT="-Sew -Oodfa" }
program zeroinit_result_dfa_11;

{$mode unleashed}

// same as zeroinit_result_managed_10 but through the DFA warning path

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
  s := 'stale';
  s := foo;
  if s <> 'x' then halt(1);
  if foo <> 'x' then halt(2);
  if bar <> 7 then halt(3);
end.
