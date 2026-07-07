{ %OPT="-O4" }
{ Recognized shape variants that must all fire and stay correct:
    * body statements in reverse order (clear then increment);
    * the counter written as  c := c + 1  instead of inc(c);
    * the unsigned  while x > 0  guard;
    * x is read after the loop and must be 0 in every form. }
program bitidiom_variants_01;
{$mode objfpc}

{ x-clear before the increment }
function popc_reversed(x: dword): longint;
var c: longint;
begin
  c := 0;
  while x <> 0 do
    begin
      x := x and (x - 1);
      inc(c);
    end;
  if x <> 0 then Halt(50);   { x must end 0 }
  popc_reversed := c;
end;

{ explicit  c := c + 1  counter step }
function popc_addassign(x: dword): longint;
var c: longint;
begin
  c := 0;
  while x <> 0 do
    begin
      c := c + 1;
      x := x and (x - 1);
    end;
  popc_addassign := c;
end;

{ unsigned  while x > 0  guard }
function popc_gt(x: dword): longint;
var c: longint;
begin
  c := 0;
  while x > 0 do
    begin
      inc(c);
      x := x and (x - 1);
    end;
  popc_gt := c;
end;

begin
  if popc_reversed(0) <> 0 then Halt(1);
  if popc_reversed($FFFFFFFF) <> 32 then Halt(2);
  if popc_reversed($AAAAAAAA) <> 16 then Halt(3);

  if popc_addassign(0) <> 0 then Halt(4);
  if popc_addassign($FF00FF00) <> 16 then Halt(5);
  if popc_addassign(7) <> 3 then Halt(6);

  if popc_gt(0) <> 0 then Halt(7);
  if popc_gt($80000000) <> 1 then Halt(8);
  if popc_gt($FFFFFFFF) <> 32 then Halt(9);
end.
