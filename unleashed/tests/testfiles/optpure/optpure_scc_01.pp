{ %OPT="-O4 -OoPURE" }
{ A mutually-recursive SCC of const functions (is_even / is_odd read only their
  by-value parameter) must still be proven const by the on-demand fixpoint, so a
  call with a loop-invariant argument is hoisted out of the loop. Correctness
  must be preserved regardless. }
program optpure_scc_01;
{$mode objfpc}

function is_odd(n: longint): boolean; forward;

function is_even(n: longint): boolean;
begin
  if n = 0 then is_even := true
  else is_even := is_odd(n - 1);
end;

function is_odd(n: longint): boolean;
begin
  if n = 0 then is_odd := false
  else is_odd := is_even(n - 1);
end;

function count_even_hits(k, iterations: longint): longint;
var
  i, c: longint;
begin
  c := 0;
  for i := 1 to iterations do
    if is_even(k) then         { k invariant -> const call hoistable }
      inc(c);
  count_even_hits := c;
end;

begin
  if count_even_hits(10, 100) <> 100 then Halt(1); { 10 even -> 100 hits }
  if count_even_hits(7, 100) <> 0 then Halt(2);    { 7 odd  -> 0 hits }
  if not is_even(0) then Halt(3);
  if not is_odd(5) then Halt(4);
end.
