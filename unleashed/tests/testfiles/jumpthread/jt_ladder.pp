{ %OPT="-O4 -OoJUMPTHREAD" %CHECKBIN_LACKS=LADDERDEADZZZ }
{$mode objfpc}
{ Chained elsif ladder: the  x<>1  fact established by the first failed arm is
  carried down the whole else chain, so the later  if x=1  re-test is decided
  false and its (dead) then-arm 'LADDERDEADZZZ' is folded away. Also checks the
  ladder still classifies correctly. }
program jt_ladder;
function ladder(x: longint): longint;
begin
  result:=0;
  if x=1 then result:=10
  else if x=2 then result:=20
  else if x=3 then result:=30
  else if x=1 then begin writeln('LADDERDEADZZZ'); result:=99; end   { x<>1 known -> dead }
  else result:=40;
end;
procedure check(g,w,id: longint); begin if g<>w then begin writeln('FAIL ',id); Halt(id); end; end;
begin
  check(ladder(1),10,1); check(ladder(2),20,2); check(ladder(3),30,3);
  check(ladder(5),40,4); check(ladder(-7),40,5);
  writeln('OK ladder'); Halt(0);
end.
