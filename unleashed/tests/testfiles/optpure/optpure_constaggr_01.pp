{ %OPT="-O4 -OoPURE -OoGVNPRE" }
{ -OoPURE eligibility broadening: a routine that reads through a const/constref
  aggregate parameter (record / fixed array / set) but never writes it is a PURE
  reader -- its field/element reads are pure memory reads, and a const parameter
  cannot be written. Such helpers now qualify, so -OoGVNPRE may common two
  identical calls to them. The result must be identical to calling every time;
  and a store into the aggregate the helper reads, between two calls, must force
  a recompute (the value is memory-dependent). A helper taking a VAR aggregate
  (writable alias) must stay impure -- its observable write is checked. Every
  kernel is validated against an independent reference. Halt(nonzero)=failure. }
program optpure_constaggr_01;
{$mode objfpc}{$H+}

type
  TVec = record x, y, z: longint; end;
  TArr = array[0..3] of longint;

var
  fails: longint;
  varwrites: longint;

procedure chk(got, want: longint; const msg: string);
begin
  if got <> want then
    begin
      writeln('FAIL ', msg, ' got=', got, ' want=', want);
      inc(fails);
    end;
end;

{ pure: reads record fields through a const-by-reference parameter }
function dot(const v: TVec): longint;
begin
  dot := v.x * v.x + v.y * v.y + v.z * v.z;
end;

{ pure: reads array elements through a const-by-reference parameter }
function asum(const a: TArr): longint;
begin
  asum := a[0] + a[1] + a[2] + a[3];
end;

{ impure: a var aggregate is a writable alias, so this must NOT be commoned }
function bump(var v: TVec): longint;
begin
  inc(varwrites);
  v.x := v.x + 1;
  bump := v.x + v.y + v.z;
end;

{ two identical const-aggregate calls across statements -> commoned }
function twice(const v: TVec; const a: TArr): longint; noinline;
var r: longint;
begin
  r := dot(v) + asum(a);
  twice := r + dot(v) + asum(a);
end;

function twice_ref(const v: TVec; const a: TArr): longint;
var d, s: longint;
begin
  d := v.x*v.x + v.y*v.y + v.z*v.z;
  s := a[0] + a[1] + a[2] + a[3];
  twice_ref := d + s + d + s;
end;

{ SOUND: a write into the record between the two dot() calls forces recompute }
function killrec(var v: TVec): longint; noinline;
var x, y: longint;
begin
  x := dot(v);
  v.y := v.y + 10;             { memory the pure reader depends on changed }
  y := dot(v);                 { must recompute, not reuse x }
  killrec := x * 100000 + y;
end;

{ SOUND: a var-parameter helper is impure -> both calls execute, both write }
function usebump(v: TVec): longint; noinline;
begin
  usebump := bump(v) + bump(v);
end;

var
  i: longint;
  v: TVec;
  a: TArr;
  xa, xb, dr, dref: longint;
begin
  fails := 0;
  for i := -3 to 3 do
    begin
      v.x := i;      v.y := i + 1;  v.z := i - 2;
      a[0] := i;     a[1] := 2*i;   a[2] := i*i;  a[3] := 7 - i;

      chk(twice(v, a), twice_ref(v, a), 'twice');

      { killrec closed form }
      xa := v.x*v.x + v.y*v.y + v.z*v.z;
      xb := v.x*v.x + (v.y+10)*(v.y+10) + v.z*v.z;
      dr := killrec(v);              { note: killrec mutates its OWN by-ref copy }
      dref := xa * 100000 + xb;
      chk(dr, dref, 'killrec');

      { impure var helper: exactly two writes per usebump call }
      varwrites := 0;
      v.x := i; v.y := i + 1; v.z := i - 2;
      dr := usebump(v);
      chk(varwrites, 2, 'usebump_writes');
      { value: first bump makes v.x=i+1 -> (i+1)+(i+1)+(i-2)=3i;
        second bump v.x=i+2 -> (i+2)+(i+1)+(i-2)=3i+1 ; sum=6i+1 }
      chk(dr, 6*i + 1, 'usebump_value');
    end;
  if fails = 0 then
    writeln('ALL OK')
  else
    halt(1);
end.
