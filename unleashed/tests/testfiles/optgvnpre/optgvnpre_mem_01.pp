{ %OPT=-O4 -OoGVNPRE }
{ -OoGVNPRE on memory-reading expressions (repeated descriptor / field loads):
  a pointer dereference or record-field load reused across statements and across
  a rejoining branch when NO store through memory and NO call intervenes -- and
  correctly reloaded once a store does intervene.  Checked against a reference.
  Halt(nonzero) = failure. }
program optgvnpre_mem_01;
{$mode objfpc}{$H+}

type
  plongint = ^longint;
  trec = record
    w, h: longint;
  end;

var
  fails: longint;

procedure chk(got, want: longint; const msg: string);
begin
  if got <> want then
    begin
      writeln('FAIL ', msg, ' got=', got, ' want=', want);
      inc(fails);
    end;
end;

{ p^ reused (no store/call between) }
function derefreuse(p: plongint; a, b: longint): longint; noinline;
var x, y: longint;
begin
  x := p^ * a;
  y := p^ * b;
  derefreuse := x + y;
end;

{ FSizeX*FSizeY-style field product reused before and on both arms }
function fieldreuse(const r: trec; cond: boolean): longint; noinline;
var s: longint;
begin
  s := r.w * r.h;
  if cond then
    fieldreuse := r.w * r.h + s
  else
    fieldreuse := r.w * r.h - s;
end;

{ store to r.w kills the field product; the second must recompute }
function fieldkill(var r: trec): longint; noinline;
var x, y: longint;
begin
  x := r.w * r.h;
  r.w := r.w + 1;
  y := r.w * r.h;
  fieldkill := x * 1000 + y;
end;

var
  v: longint;
  rr: trec;
  i, j: longint;
begin
  fails := 0;

  for i := -6 to 6 do
    begin
      v := i;
      chk(derefreuse(@v, 3, 5), (i * 3) + (i * 5), 'derefreuse');
    end;

  for i := -5 to 5 do
    for j := -5 to 5 do
      begin
        rr.w := i; rr.h := j;
        chk(fieldreuse(rr, true), i * j + i * j, 'fieldreuse-t');
        chk(fieldreuse(rr, false), (i * j) - (i * j), 'fieldreuse-f');
        rr.w := i; rr.h := j;
        chk(fieldkill(rr), (i * j) * 1000 + ((i + 1) * j), 'fieldkill');
      end;

  if fails = 0 then
    writeln('ALL OK')
  else
    halt(1);
end.
