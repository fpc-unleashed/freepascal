{ %OPT=-O4 }
{ Shapes where clustering must NOT change behaviour (and mostly must not fire):
  too few labels to beat one-compare-per-label, a single label, a lone dense run
  the classic jump-table heuristic already owns, a boolean selector, an enum, and
  a widestring/string case (non-ordinal, handled by a different code path and
  never touched by the ordinal clustering).  All must compile and stay correct. }
program casecluster_negatives_01;
{$mode objfpc}{$H+}

type TColour = (cRed, cGreen, cBlue, cAmber, cViolet);

{ two labels: below the clustering threshold, stays a compare pair }
function ftwo(x: longint): longint;
begin
  case x of
    3: ftwo:=1;
    9: ftwo:=2;
  else ftwo:=0;
  end;
end;

{ single label }
function fone(x: longint): longint;
begin
  case x of
    42: fone:=7;
  else fone:=0;
  end;
end;

{ one dense contiguous run -> lone jump-table cluster, left to the tuned default }
function frun(x: longint): longint;
begin
  case x of
    10..25: frun:=x*2;
  else frun:=-1;
  end;
end;

function fenum(c: TColour): longint;
begin
  case c of
    cRed: fenum:=1;
    cGreen: fenum:=2;
    cBlue: fenum:=3;
    cAmber: fenum:=4;
    cViolet: fenum:=5;
  end;
end;

function fbool(b: boolean): longint;
begin
  case b of
    false: fbool:=100;
    true: fbool:=200;
  end;
end;

{ non-ordinal selector: exercised, must be unaffected by ordinal clustering }
function fstr(const s: string): longint;
begin
  case s of
    'alpha': fstr:=1;
    'beta': fstr:=2;
    'gamma','delta': fstr:=3;
  else fstr:=0;
  end;
end;

var i: longint; col: TColour;
begin
  for i:=-5 to 60 do
    begin
      if ftwo(i)<>(ord(i=3)*1 + ord(i=9)*2) then Halt(1);
      if fone(i)<>(ord(i=42)*7) then Halt(2);
      if (i>=10) and (i<=25) then
        begin if frun(i)<>i*2 then Halt(3); end
      else
        if frun(i)<>-1 then Halt(4);
    end;

  if fenum(cRed)<>1 then Halt(5);
  if fenum(cGreen)<>2 then Halt(6);
  if fenum(cBlue)<>3 then Halt(7);
  if fenum(cAmber)<>4 then Halt(8);
  if fenum(cViolet)<>5 then Halt(9);
  for col:=cRed to cViolet do
    if fenum(col)<>ord(col)+1 then Halt(10);

  if fbool(false)<>100 then Halt(11);
  if fbool(true)<>200 then Halt(12);

  if fstr('alpha')<>1 then Halt(13);
  if fstr('beta')<>2 then Halt(14);
  if fstr('gamma')<>3 then Halt(15);
  if fstr('delta')<>3 then Halt(16);
  if fstr('zzz')<>0 then Halt(17);

  Writeln('OK');
  Halt(0);
end.
