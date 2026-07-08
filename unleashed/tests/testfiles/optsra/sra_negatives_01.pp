{ %OPT=-O4 }
{ SRA must DECLINE (leave the record in memory) whenever its address could
  escape, and the program must still be correct.  Each routine below hits one
  hard gate: address-of the record / a field, passing the record by var, passing
  a field by var, whole-record assignment, a variant (case) part, a managed
  (ansistring) field, and Default()/FillChar zeroing.  If SRA wrongly fired on
  any of these the observable result would change, so behavioural equality is
  the check.  (with_stmt is a control: FPC lowers `with p do` over a simple
  local record into plain rec.field subscripts with no hidden pointer, so the
  escape walk legitimately permits it and the result stays correct -- the
  "resolve" rather than "decline" outcome.) }
program sra_negatives_01;
{$mode objfpc}{$H+}

type
  TP = record x, y: longint; end;
  TVar = record
    case kind: byte of
      0: (i: longint);
      1: (b: array[0..3] of byte);
  end;
  TMan = record s: ansistring; n: longint; end;

procedure bump(var p: TP); begin p.x := p.x + 100; p.y := p.y + 200; end;
procedure incby(var v: longint; d: longint); begin v := v + d; end;

{ address of the whole record taken }
function addr_of_rec(a: longint): longint;
var p: TP; q: ^TP;
begin
  p.x := a; p.y := a * 2;
  q := @p;
  q^.x := q^.x + 5;
  addr_of_rec := p.x + p.y;
end;

{ address of a field taken }
function addr_of_field(a: longint): longint;
var p: TP; pi: PLongint;
begin
  p.x := a; p.y := 0;
  pi := @p.x;
  pi^ := pi^ + 9;
  addr_of_field := p.x + p.y;
end;

{ whole record passed by var }
function var_record(a: longint): longint;
var p: TP;
begin
  p.x := a; p.y := a;
  bump(p);
  var_record := p.x + p.y;
end;

{ a field passed by var }
function var_field(a: longint): longint;
var p: TP;
begin
  p.x := a; p.y := a;
  incby(p.x, 50);
  var_field := p.x + p.y;
end;

{ whole-record assignment rec := other }
function whole_copy(a: longint): longint;
var p, r: TP;
begin
  p.x := a; p.y := a + 1;
  r := p;
  r.x := r.x + 3;
  whole_copy := p.x + p.y + r.x + r.y;
end;

{ with statement }
function with_stmt(a: longint): longint;
var p: TP;
begin
  with p do begin x := a; y := a * 3; end;
  with_stmt := p.x + p.y;
end;

{ variant / case part }
function variant_rec(a: longint): longint;
var v: TVar;
begin
  v.i := a;
  variant_rec := v.b[0] + v.i;
end;

{ managed (ansistring) field: ref-counting must be preserved }
function managed_rec(a: longint): longint;
var m: TMan;
begin
  m.s := 'abc';
  m.n := a;
  m.s := m.s + 'de';
  managed_rec := Length(m.s) + m.n;
end;

{ Default() / FillChar zeroing }
function zeroed(a: longint): longint;
var p: TP;
begin
  FillChar(p, SizeOf(p), 0);
  p.x := p.x + a;
  zeroed := p.x + p.y;
end;

begin
  if addr_of_rec(4) <> (4+5) + 8 then Halt(1);
  if addr_of_field(4) <> (4+9) + 0 then Halt(2);
  if var_record(4) <> (4+100) + (4+200) then Halt(3);
  if var_field(4) <> (4+50) + 4 then Halt(4);
  if whole_copy(4) <> (4 + 5 + (4+3) + 5) then Halt(5);
  if with_stmt(4) <> 4 + 12 then Halt(6);
  if variant_rec(5) <> 5 + 5 then Halt(7);       { b[0] is low byte of i=5 }
  if managed_rec(10) <> 5 + 10 then Halt(8);     { 'abcde' length 5 }
  if zeroed(9) <> 9 + 0 then Halt(9);
end.
