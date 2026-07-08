{ %OPT=-O4 -OoGVNPRE }
{ -OoGVNPRE correctness oracle: a side-effect-free scalar expression whose value
  is already available on every path (computed on a dominating statement / before
  a branch and reused on the rejoining arms, or recomputed across straight-line
  bodies) is computed once into a temp and reused.  This must be observationally
  identical to recomputing it every time.  Every kernel is checked against an
  independently-written reference over the FULL cross product of a range of
  inputs, so a wrong reuse (using a stale value, hoisting past a kill, or
  eliminating a computation that was not actually redundant) is caught.
  Halt(nonzero) = failure. }
program optgvnpre_correct_01;
{$mode objfpc}{$H+}

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

{ base-offset/stride shape: channel*size reused before, on both arms, and after }
function stride(channel, size: longint; cond: boolean): longint; noinline;
var r, base: longint;
begin
  base := channel * size + 1;
  if cond then
    r := channel * size + base
  else
    r := channel * size - base;
  stride := r + channel * size;
end;

function stride_ref(channel, size: longint; cond: boolean): longint;
var r, base, cs: longint;
begin
  cs := channel * size;
  base := cs + 1;
  if cond then r := cs + base else r := cs - base;
  stride_ref := r + cs;
end;

{ straight-line "unrolled body" reuse of a common subexpression }
function unrolled(a, b, c: longint): longint; noinline;
var t0, t1, t2, t3: longint;
begin
  t0 := (a + b) * c;
  t1 := (a + b) * c + 1;
  t2 := (a + b) * c + 2;
  t3 := (a + b) * c + 3;
  unrolled := t0 + t1 + t2 + t3;
end;

function unrolled_ref(a, b, c: longint): longint;
var e: longint;
begin
  e := (a + b) * c;
  unrolled_ref := e + (e + 1) + (e + 2) + (e + 3);
end;

{ two dominating expressions carried into a nested if }
function nested(x, y: longint; c1, c2: boolean): longint; noinline;
var r: longint;
begin
  r := x * y;
  if c1 then
    begin
      if c2 then r := r + x * y + (x + y)
      else r := r - x * y - (x + y);
    end
  else
    r := r + (x + y) - x * y;
  nested := r + (x + y);
end;

function nested_ref(x, y: longint; c1, c2: boolean): longint;
var r, xy, xpy: longint;
begin
  xy := x * y; xpy := x + y;
  r := xy;
  if c1 then
    begin
      if c2 then r := r + xy + xpy else r := r - xy - xpy;
    end
  else
    r := r + xpy - xy;
  nested_ref := r + xpy;
end;

var
  a, b, c, d: longint;
begin
  fails := 0;
  for a := -4 to 4 do
    for b := -4 to 4 do
      for c := -3 to 3 do
        begin
          chk(stride(a, b, (c and 1) = 0), stride_ref(a, b, (c and 1) = 0), 'stride');
          chk(unrolled(a, b, c), unrolled_ref(a, b, c), 'unrolled');
          for d := 0 to 3 do
            chk(nested(a, b, (c and 1) = 0, (d and 1) = 0),
                nested_ref(a, b, (c and 1) = 0, (d and 1) = 0), 'nested');
        end;
  if fails = 0 then
    writeln('ALL OK')
  else
    halt(1);
end.
