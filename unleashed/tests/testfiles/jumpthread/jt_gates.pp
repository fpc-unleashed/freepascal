{ %OPT="-O4 -OoJUMPTHREAD" }
{$mode objfpc}
{ Soundness gates: in each function a naive "outer decides inner" fold would be
  WRONG; the pass must NOT fold, so the runtime result must reflect the real
  (post-modification / non-simple-variable) value. Halt(n) on any wrong fold. }
program jt_gates;

var g: longint;              { global -> never a valid fact (callee/other thread) }
threadvar tv: longint;       { threadvar -> vo_is_thread_var, rejected like volatile }

procedure bumpg;  begin g:=3;  end;
procedure bumptv; begin tv:=3; end;
procedure noop(z: longint); begin if z<0 then g:=z; end;  { a call that leaves locals alone }

{ intervening assignment kills the fact: y becomes 0, so y>5 is false -> 2 }
function gate_assign(y: longint): longint;
begin
  result:=0;
  if y>10 then
    begin
      y:=0;
      if y>5 then result:=1 else result:=2;
    end;
end;

{ address-taken y: a store through the pointer changes y -> y>5 false -> 2 }
function gate_addr(y: longint): longint;
var p: ^longint;
begin
  result:=0;
  p:=@y;
  if y>10 then
    begin
      p^:=0;
      if y>5 then result:=1 else result:=2;
    end;
end;

{ global g: not a local/param -> no fact; a call changes it -> g>5 false -> 3 }
function gate_global: longint;
begin
  result:=0;
  g:=42;
  if g>10 then
    begin
      result:=1;
      bumpg;
      if g>5 then result:=2 else result:=3;
    end;
end;

{ threadvar tv: rejected like volatile -> no fact; call changes it -> tv>5 false -> 3 }
function gate_threadvar: longint;
begin
  result:=0;
  tv:=42;
  if tv>10 then
    begin
      result:=1;
      bumptv;
      if tv>5 then result:=2 else result:=3;
    end;
end;

{ a call between the tests does NOT block folding for a non-address-taken local:
  the callee cannot reach y, so y>5 is still implied true -> 1 (correct fold) }
function gate_call_ok(y: longint): longint;
begin
  result:=0;
  if y>10 then
    begin
      noop(y);
      if y>5 then result:=1 else result:=2;
    end;
end;

procedure check(got,want: longint; id: longint);
begin
  if got<>want then begin writeln('FAIL gate ',id,' got ',got,' want ',want); Halt(id); end;
end;

begin
  check(gate_assign(42),    2, 1);
  check(gate_addr(42),      2, 2);
  check(gate_global,        3, 3);
  check(gate_threadvar,     3, 4);
  check(gate_call_ok(42),   1, 5);
  writeln('OK gates');
  Halt(0);
end.
