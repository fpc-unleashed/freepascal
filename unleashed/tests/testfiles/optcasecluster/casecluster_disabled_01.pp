{ %OPT="-O4 -OoNOCASECLUSTER" %CHECKBIN_LACKS=!$HP }
{ Negative control for casecluster_bittest_01: the SAME eight-label sparse case,
  compiled with clustering explicitly disabled, must NOT produce the bit-test
  AND-mask, so the tag "!$HP" ($50482421's little-endian bytes) is asserted
  ABSENT by %CHECKBIN_LACKS.  Without clustering the classic linear-list lowering
  emits a compare chain instead.  Behaviour is of course still identical -- every
  input is checked against the reference. }
program casecluster_disabled_01;
{$mode objfpc}{$H+}

function f(c: char): integer;
begin
  case c of
    'A','F','K','N','T','W',']','_': f:=7;
  else
    f:=0;
  end;
end;

function ref(c: char): integer;
begin
  if (c='A') or (c='F') or (c='K') or (c='N') or
     (c='T') or (c='W') or (c=']') or (c='_') then ref:=7 else ref:=0;
end;

var i: integer;
begin
  for i:=0 to 255 do
    if f(chr(i))<>ref(chr(i)) then Halt(1);
  Writeln('OK');
  Halt(0);
end.
