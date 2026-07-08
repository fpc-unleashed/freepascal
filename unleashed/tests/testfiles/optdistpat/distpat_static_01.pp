{ %OPT="-O4 -OoLOOPDISTPAT" }
{ Normal (non-open, non-bitpacked) static arrays are contiguous, so zero and
  non-zero fills over them also lower to a block primitive. A partial-range fill
  (lo..hi a sub-slice) must touch exactly that slice and leave the rest intact.
  Static-array element copy is NOT lowered (a shifted overlap cannot be excluded
  for two static arrays) but must still compute correctly. }
program distpat_static_01;
{$mode objfpc}{$H+}

function run: longint;
var
  a: array[0..63] of longint;
  w: array[0..15] of word;
  b,c: array[0..31] of longint;
  i: longint;
begin
  { full zero-fill }
  for i:=0 to 63 do a[i]:=i+1;
  for i:=0 to 63 do a[i]:=0;
  for i:=0 to 63 do if a[i]<>0 then Halt(1);

  { non-zero word fill }
  for i:=0 to 15 do w[i]:=$BEEF;
  for i:=0 to 15 do if w[i]<>$BEEF then Halt(2);

  { partial-range fill: only 10..40 set to 5, rest must remain 0 }
  for i:=0 to 63 do a[i]:=0;
  for i:=10 to 40 do a[i]:=5;
  for i:=0 to 63 do
    if ((i>=10) and (i<=40)) then begin if a[i]<>5 then Halt(3); end
    else if a[i]<>0 then Halt(4);

  { static-array element copy (declined but correct) }
  for i:=0 to 31 do c[i]:=i*11-1;
  for i:=0 to 31 do b[i]:=c[i];
  for i:=0 to 31 do if b[i]<>i*11-1 then Halt(5);

  run:=0;
end;

begin
  if run<>0 then Halt(9);
end.
