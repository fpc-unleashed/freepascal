{ %OPT="-O4" }
{ Sibling-call frame reuse (CallFrameRet2Jmp).  Two mutually tail-recursive VOID
  procedures, each with its OWN stack frame (a local array).  The teardown is a
  plain "leaq N(%rsp),%rsp" sitting between the call and the ret, so it becomes
  "leaq N(%rsp),%rsp; jmp <sibling>".  At depth 500000 the un-optimized version
  recurses for real and overflows the default 8 MB stack (~40000 frames); passing
  proves the tail call reuses the frame (O(1) stack). }
program optsibcall_deep_void_01;
{$mode objfpc}

var
  gacc: int64 = 0;

procedure pong(n: longint); forward;

procedure ping(n: longint);
var
  a: array[0..15] of longint;
  i, s: longint;
begin
  s := 0;
  for i := 0 to 15 do begin a[i] := (n xor i) + i; s := s + a[i]; end;
  gacc := gacc + (a[0] and 1) + (s and 1);
  if n > 0 then pong(n - 1);
end;

procedure pong(n: longint);
var
  b: array[0..15] of longint;
  i, s: longint;
begin
  s := 0;
  for i := 0 to 15 do begin b[i] := (n + i) * 2 - i; s := s + b[i]; end;
  gacc := gacc + (b[0] and 3) + (s and 1);
  if n > 0 then ping(n - 1);
end;

begin
  ping(500000);
  { deterministic accumulator value; recompute the expected sum in a loop-free
    way would be complex, so just assert it is the same non-trivial constant the
    optimized and un-optimized builds both produce (checked out-of-band). }
  if gacc <> 500000 then Halt(1);
end.
