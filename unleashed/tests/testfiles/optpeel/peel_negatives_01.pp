{ %OPT="-O4 -OoLOOPPEEL -vn" }
{ Shapes the peel pass must decline, each emitting a cg_n_loop_not_peeled (06070)
  note naming the reason; every loop must still compute the same result as the
  scalar code. Declines covered: break in body, continue in body, non-unit step,
  and a global (non-local) counter. }
program peel_negatives_01;
{$mode unleashed}

function body(i: longint): longint;
begin
  body:=i*i + (i shl 2) - (i xor 3) + 1;
end;

{ break: pass must decline (control flow); loop stops early at i=3 }
function with_break(var a: array of longint): longint;
var i, c: longint;
begin
  c:=0;
  for i:=0 to 7 do
    begin
      if i=4 then break;
      a[i]:=body(i);
      c:=c+1;
    end;
  with_break:=c;
end;

{ continue: pass must decline; even indices skipped }
function with_continue(var a: array of longint): longint;
var i, c: longint;
begin
  c:=0;
  for i:=0 to 7 do
    begin
      if (i and 1)=0 then continue;
      a[i]:=body(i);
      c:=c+1;
    end;
  with_continue:=c;
end;

{ non-unit step: pass must decline }
function with_step(var a: array of longint): longint;
var i, c: longint;
begin
  c:=0;
  for i:=0 to 7 step 2 do
    begin
      a[i]:=body(i) + (i shl 1) - (i xor 5) + (i*i) - 2;
      c:=c+1;
    end;
  with_step:=c;
end;

var
  gi: longint;
  ga: array[0..7] of longint;

{ global counter: pass must decline }
procedure with_global;
begin
  for gi:=0 to 7 do
    ga[gi]:=body(gi) + (gi shl 1) - (gi xor 5) + (gi*gi) - 2;
end;

var
  a: array[0..7] of longint;
  i: longint;
begin
  for i:=0 to 7 do a[i]:=-1;
  if with_break(a)<>4 then Halt(1);
  for i:=0 to 3 do if a[i]<>body(i) then Halt(2);

  for i:=0 to 7 do a[i]:=-1;
  if with_continue(a)<>4 then Halt(3);
  for i:=0 to 7 do
    if (i and 1)=1 then
      begin if a[i]<>body(i) then Halt(4); end
    else
      if a[i]<>-1 then Halt(5);

  for i:=0 to 7 do a[i]:=-1;
  if with_step(a)<>4 then Halt(6);
  if (a[0]=-1) or (a[2]=-1) or (a[4]=-1) or (a[6]=-1) then Halt(7);
  if (a[1]<>-1) or (a[3]<>-1) then Halt(8);

  for i:=0 to 7 do ga[i]:=-1;
  with_global;
  for i:=0 to 7 do
    if ga[i]<>body(i)+(i shl 1)-(i xor 5)+(i*i)-2 then Halt(10);

  writeln('ok');
end.
