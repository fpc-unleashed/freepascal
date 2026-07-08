{ %OPT="-O4" }
{ Negative case: a routine that passes a pointer to its OWN stack local to the
  callee must NOT get sibling-call frame reuse, otherwise the frame would be torn
  down before the jump and the callee would read a dangling pointer.  The pass
  gates on address-taken locals/parameters, so the call is retained.  Behaviourally
  the callee must observe valid data; the accumulated sum verifies this. }
program optsibcall_ptr_negative_01;
{$mode objfpc}

var
  total: int64 = 0;

procedure consume(p: plongint; depth: longint);
begin
  { read through the pointer into the caller's (still live) frame }
  total := total + p^;
  if depth > 0 then
    ; { nothing }
end;

procedure src(n: longint);
var
  a: array[0..7] of longint;
  i: longint;
begin
  for i := 0 to 7 do a[i] := n * 10 + i;
  if n > 0 then
    consume(@a[3], n);   { @local -> address taken, must keep the call }
  if n > 1 then
    src(n - 1);
end;

begin
  src(5);
  { a[3] at n=5..1 is n*10+3 -> 53+43+33+23+13 = 165 }
  if total <> 165 then Halt(1);
end.
