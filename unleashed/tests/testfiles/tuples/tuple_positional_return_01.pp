{$mode unleashed}
program tuple_positional_return_01;

uses
  SysUtils;

{ positional tuple as function return type, accessed via _N fields }

function Pair: (Integer, Integer);
begin
  Result._1 := 10;
  Result._2 := 20;
end;

function Triple: (Integer, Integer, Integer);
begin
  Result._1 := 1;
  Result._2 := 2;
  Result._3 := 3;
end;

function Mixed: (Integer, String);
begin
  Result._1 := 42;
  Result._2 := 'hello';
end;

var
  p: (Integer, Integer);
  t: (Integer, Integer, Integer);
  m: (Integer, String);
begin
  p := Pair;
  if (p._1 <> 10) or (p._2 <> 20) then Halt(1);

  t := Triple;
  if (t._1 <> 1) or (t._2 <> 2) or (t._3 <> 3) then Halt(2);

  m := Mixed;
  if (m._1 <> 42) or (m._2 <> 'hello') then Halt(3);

  { inline access on function result }
  if Pair._1 <> 10 then Halt(10);
  if Triple._3 <> 3 then Halt(11);

  WriteLn('OK');
end.
