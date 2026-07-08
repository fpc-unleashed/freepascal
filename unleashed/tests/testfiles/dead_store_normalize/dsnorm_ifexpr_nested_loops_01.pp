{ %OPT="-O3 -Oodeadstore" }
{ Regression: a statement-expression buried two loops deep must be normalized
  relative to its own enclosing statement, not hoisted out to the outermost one.
  Verifies the second-phase (per-nested-statement) normalization. }
program dsnorm_ifexpr_nested_loops_01;
{$mode unleashed}
var
  i, j, hits: longint;
begin
  hits := 0;
  for i := 0 to 2 do
    for j := 0 to 2 do
    begin
      var tag := if i = j then 'diag'
                 else if i < j then 'upper'
                 else 'lower';
      if (i = j) and (tag <> 'diag')  then Halt(1);
      if (i < j) and (tag <> 'upper') then Halt(2);
      if (i > j) and (tag <> 'lower') then Halt(3);
      if tag = 'diag' then Inc(hits);
    end;
  if hits <> 3 then Halt(4);
end.
