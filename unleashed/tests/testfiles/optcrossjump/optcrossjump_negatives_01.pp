{ %OPT="-O4" }
{ Negative cross-jumping cases -- each must stay correct at -O4.  A wrong merge
  would corrupt a result and Halt with the case number.
    * tails that look similar but differ in one operand ($7 vs $8) must NOT be
      merged into a single tail;
    * a live label (goto target) sitting inside one tail must block the
      backward walk, so the surrounding instructions are never merged across
      it. }
program optcrossjump_negatives_01;
{$mode objfpc}

{ differing final operand between two otherwise-identical tails }
function differ(x: longint): longint; noinline;
var
  a: longint;
begin
  a := 0;
  if x = 1 then begin a := a + 1; a := a * 3; a := a + 7; Exit(a); end;
  if x = 2 then begin a := a + 1; a := a * 3; a := a + 8; Exit(a); end;
  a := a + 1; a := a * 3; a := a + 9;
  Result := a;
end;

{ a live label in the middle of the shared-looking region }
function withlabel(x: longint): longint; noinline;
label
  L;
var
  a: longint;
begin
  a := 0;
  if x = 1 then begin a := a + 5; goto L; end;
  a := a + 1;
  a := a * 3;
L:
  a := a + 7;
  Result := a;
end;

begin
  { differ: x=1 -> (0+1)*3+7 = 10 ; x=2 -> (0+1)*3+8 = 11 ; else -> (0+1)*3+9 = 12 }
  if differ(1) <> 10 then Halt(1);
  if differ(2) <> 11 then Halt(2);
  if differ(5) <> 12 then Halt(3);

  { withlabel: x=1 -> (0+5)+7 = 12 ; else -> ((0+1)*3)+7 = 10 }
  if withlabel(1) <> 12 then Halt(4);
  if withlabel(9) <> 10 then Halt(5);

  Writeln('OK');
end.
