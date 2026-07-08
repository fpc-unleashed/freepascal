{ %OPT="-O3 -Oodeadstore" }
{ Extended DSE: a redundant record-field store (later overwritten before any
  read) is removed, yet the routine computes the correct result. }
program dead_store_ext_record_field_01;
{$mode objfpc}
type
  TRec = record a, b, c: longint; end;
var
  g: longint;

procedure Fill(x: longint);
var
  r: TRec;
begin
  r.a := x + 111;   { dead: overwritten by r.a below before any read }
  r.b := x + 222;
  r.a := x + 5;     { live }
  r.c := x + 7;
  g := r.a + r.b + r.c;
end;

begin
  Fill(33);
  if g <> (33 + 5) + (33 + 222) + (33 + 7) then
    Halt(1);
  Fill(0);
  if g <> 5 + 222 + 7 then
    Halt(2);
end.
