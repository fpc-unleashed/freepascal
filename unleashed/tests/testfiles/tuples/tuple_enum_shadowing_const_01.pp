program tuple_enum_shadowing_const_01;

{$mode unleashed}

uses
  sysutils;

type
  { mkNone is already in scope as a TFilenameCaseMatch member; redeclaring it
    must not push the parser onto the tuple path }
  TKind = (mkNone, mkNote);
  TPair = (integer, string);

var
  k : TKind;
  p : TPair;
begin
  k:=mkNote;
  if ord(k)<>1 then
    halt(1);
  p:=(7, 'x');
  if (p._1<>7) or (p._2<>'x') then
    halt(2);
end.
