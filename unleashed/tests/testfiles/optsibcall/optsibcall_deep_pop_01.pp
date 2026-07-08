{ %OPT="-O4" }
{ Sibling-call frame reuse with a callee-saved register in the teardown.  A value
  (keep) is held live across an inner call, forcing it into a callee-saved
  register, so the epilogue is "leaq N(%rsp),%rsp; popq %r..; popq %rbx; ret".
  The pass hoists the whole teardown (stack release + callee-saved pops, which are
  never argument registers) above the tail call and turns it into a jmp.  Depth
  400000 overflows the default stack unless the frame is reused. }
program optsibcall_deep_pop_01;
{$mode objfpc}

var
  gacc: int64 = 0;

procedure helper; begin gacc := gacc + 1; end;

procedure pong(n: longint); forward;

procedure ping(n: longint);
var
  a: array[0..7] of longint;
  i, keep: longint;
begin
  keep := n * 7 + 3;
  for i := 0 to 7 do a[i] := n + i;
  helper;                        { clobbers volatiles; keep survives -> callee-saved reg }
  gacc := gacc + (keep and 1) + (a[0] and 1);
  if n > 0 then pong(n - 1);
end;

procedure pong(n: longint);
var
  a: array[0..7] of longint;
  i, keep: longint;
begin
  keep := n + 5;
  for i := 0 to 7 do a[i] := n - i;
  helper;
  gacc := gacc + (keep and 3) + (a[0] and 1);
  if n > 0 then ping(n - 1);
end;

begin
  ping(400000);
  if gacc <> 1000002 then Halt(1);
end.
