{ %OPT="-O4" }
{ LICM must not treat a managed-type operation as a hoistable arithmetic
  expression: string "+" is concatenation (allocates, is not exception-free),
  so it stays in the loop. The loop-invariant concat is left in place and the
  result must still be correct. }
program licm_string_concat_01;
{$mode objfpc}{$H+}

function work(const a, b: string; n: longint): longint;
var
  i, total: longint;
  s: string;
begin
  total := 0;
  for i := 1 to n do
    begin
      s := a + b;              { invariant string concat -- must NOT be hoisted as arithmetic }
      total := total + Length(s);
    end;
  work := total;
end;

begin
  if work('foo', 'bar', 4) <> 24 then Halt(1);   { 4 * Length('foobar')=4*6=24 }
end.
