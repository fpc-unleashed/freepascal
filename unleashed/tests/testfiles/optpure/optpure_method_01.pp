{ %OPT="-O4 -OoPURE -OoGVNPRE" }
{ -OoPURE proves read-only instance methods (a  function GetX:...;begin
  Result:=FX end  accessor) pure, and -OoGVNPRE commons two identical calls on
  the same object when nothing that could touch the object's state intervenes.
  The result must be observationally identical to calling the getter every time.
  The SOUND kernels mutate a field (or make a call, or reassign the object)
  between two getter calls, so a value-number that wrongly reused a stale result
  is caught. Everything is checked against an independently-written reference
  over a cross product of inputs; Halt(nonzero)=failure. }
program optpure_method_01;
{$mode objfpc}{$H+}
{$modeswitch advancedrecords}

var
  fails: longint;
  sideg: longint;

procedure chk(got, want: longint; const msg: string);
begin
  if got <> want then
    begin
      writeln('FAIL ', msg, ' got=', got, ' want=', want);
      inc(fails);
    end;
end;

type
  { by-value record self: reading a field of self is a pure memory read }
  TPoint = record
    x, y: longint;
    function SumSq: longint;
  end;

  TCounter = class
  private
    FV: longint;
  public
    constructor Create(v: longint);
    function GetV: longint;          { read-only class getter }
    procedure Bump;                  { writes FV -> a store to the object }
  end;

function TPoint.SumSq: longint;
begin
  Result := x * x + y * y;
end;

constructor TCounter.Create(v: longint);
begin
  FV := v;
end;

function TCounter.GetV: longint;
begin
  Result := FV;
end;

procedure TCounter.Bump;
begin
  FV := FV + 1;
end;

{ an impure routine the getter cannot see through }
procedure touch; noinline;
begin
  inc(sideg);
end;

{ --- record-self getter commoned (no intervening store) ------------------ }
function recreuse(const p: TPoint): longint; noinline;
var a, b: longint;
begin
  a := p.SumSq;
  b := p.SumSq + p.SumSq;   { 2nd and 3rd calls are redundant, may common }
  recreuse := a + b;
end;

function recreuse_ref(const p: TPoint): longint;
var e: longint;
begin
  e := p.SumSq;
  recreuse_ref := e + e + e;
end;

{ --- SOUND: a field write between two class getter calls must NOT common - }
function classfieldkill(c: TCounter): longint; noinline;
var x, y: longint;
begin
  x := c.GetV;
  c.Bump;                   { writes c.FV: the value MUST change }
  y := c.GetV;
  classfieldkill := x * 1000 + y;
end;

{ --- SOUND: a call between two getter calls must NOT common -------------- }
function classcallkill(c: TCounter): longint; noinline;
var x, y: longint;
begin
  x := c.GetV;
  touch;                    { an opaque call: barrier, must reload }
  y := c.GetV;
  classcallkill := x * 1000 + y;
end;

{ --- SOUND: reassigning the object variable must NOT common -------------- }
function classreassign(c, d: TCounter): longint; noinline;
var x, y: longint;
begin
  x := c.GetV;
  c := d;                   { now a different object }
  y := c.GetV;
  classreassign := x * 1000 + y;
end;

var
  p: TPoint;
  c, d: TCounter;
  i, j: longint;
begin
  fails := 0;
  sideg := 0;

  for i := -4 to 4 do
    for j := -4 to 4 do
      begin
        p.x := i; p.y := j;
        chk(recreuse(p), recreuse_ref(p), 'recreuse');
      end;

  for i := 0 to 20 do
    begin
      c := TCounter.Create(i);
      { GetV=i, Bump -> i+1, GetV=i+1 }
      chk(classfieldkill(c), i * 1000 + (i + 1), 'classfieldkill');
      c.Free;

      c := TCounter.Create(i);
      chk(classcallkill(c), i * 1000 + i, 'classcallkill');
      c.Free;

      c := TCounter.Create(i);
      d := TCounter.Create(i + 500);
      chk(classreassign(c, d), i * 1000 + (i + 500), 'classreassign');
      c.Free; d.Free;
    end;

  if fails = 0 then
    writeln('ALL OK')
  else
    halt(1);
end.
