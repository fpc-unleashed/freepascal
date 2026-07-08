{ %OPT="-O3 -Oodeadstore" }
{ Extended DSE safety matrix: stores that must NOT be eliminated.
    - a field read before the overwrite keeps the first store;
    - a call that could observe the field is a barrier;
    - an address-taken base is never touched;
    - a managed (ansistring) field store keeps its finalization semantics.
  Every branch must compute the correct value; a wrongly removed store would
  corrupt one of them. }
program dead_store_ext_safety_01;
{$mode objfpc}{$H+}
type
  TRec = record a, b: longint; end;
  TSRec = record s: ansistring; n: longint; end;
var
  g: longint;
  gs: ansistring;

{ 1. store then READ then overwrite -> first store is live }
function ReadBetween(x: longint): longint;
var r: TRec;
begin
  r.a := x + 10;
  g := r.a;            { read: r.a := x+10 must survive }
  r.a := x + 20;
  Result := g + r.a;
end;

{ 2. store then CALL that reads the field -> barrier }
procedure Sink(const r: TRec);
begin g := r.a; end;

function CallBarrier(x: longint): longint;
var r: TRec;
begin
  r.a := x + 5;
  Sink(r);             { call observes r.a -> store must survive }
  r.a := x + 6;
  Result := g + r.a;
end;

{ 3. address-taken base -> never touched }
function AddrTaken(x: longint): longint;
var r: TRec; p: ^longint;
begin
  r.a := x + 8;        { @r.a taken below -> store must survive }
  p := @r.a;
  r.a := x + 9;
  Result := p^;        { == x+9 }
end;

{ 4. managed field store must keep refcount semantics }
function ManagedField(x: longint): longint;
var r: TSRec;
begin
  r.s := 'first';      { managed store: must not be dropped }
  r.s := 'second';
  r.n := x;
  gs := r.s;
  Result := Length(r.s) + r.n;
end;

begin
  if ReadBetween(1) <> (1 + 10) + (1 + 20) then Halt(1);
  if CallBarrier(0) <> (0 + 5) + (0 + 6) then Halt(2);
  if AddrTaken(0) <> 9 then Halt(3);
  if ManagedField(7) <> Length('second') + 7 then Halt(4);
  if gs <> 'second' then Halt(5);
end.
