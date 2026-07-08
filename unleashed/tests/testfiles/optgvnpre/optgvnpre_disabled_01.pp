{ %OPT=-O4 -OoNOGVNPRE }
{ Disabled-switch control: the SAME kernels as optgvnpre_correct_01 compiled with
  GVN-PRE explicitly OFF must still produce the correct results, proving the test
  sources are valid independently of the pass and that any behaviour change would
  be attributable to GVN-PRE alone.  Halt(nonzero) = failure. }
program optgvnpre_disabled_01;
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

var
  a, b, c: longint;
begin
  fails := 0;
  for a := -4 to 4 do
    for b := -4 to 4 do
      for c := -3 to 3 do
        begin
          chk(stride(a, b, (c and 1) = 0), stride_ref(a, b, (c and 1) = 0), 'stride');
          chk(unrolled(a, b, c), unrolled_ref(a, b, c), 'unrolled');
        end;
  if fails = 0 then
    writeln('ALL OK')
  else
    halt(1);
end.
