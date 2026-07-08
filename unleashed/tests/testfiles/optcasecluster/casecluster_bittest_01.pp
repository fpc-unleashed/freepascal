{ %OPT=-O4 %CHECKBIN_HAS=!$HP }
{ Bit-test cluster evidence.  Eight sparse char labels that all map to the same
  arm sit within a 31-value span (density ~26%, below the jump-table threshold),
  so -OoCASECLUSTER lowers them to one range check plus a single shift + AND-mask
  membership test rather than a chain of eight compares.  The labels were chosen
  so the composed little-endian mask is exactly $50482421, whose bytes 21 24 48
  50 spell the ASCII tag "!$HP" -- asserted present in the binary by
  %CHECKBIN_HAS.  The companion casecluster_disabled_01 compiles the identical
  source with -OoNOCASECLUSTER and asserts the tag is ABSENT, proving the mask is
  the clustering pass's doing and not a coincidence.  The arm value is also read
  back for every input to confirm the lowering is semantically correct. }
program casecluster_bittest_01;
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
