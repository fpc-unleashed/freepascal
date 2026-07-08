{ %OPT="-O4" }
{ Cross-jumping / tail merging at -O4.  Several guarded exits of classify()
  share the same trailing sequence (four global stores computing g1..g4 then
  the epilogue jump).  -OoCROSSJUMP keeps one copy of that tail and redirects
  the other predecessors into it; every path must still compute the same
  globals and return the same value.  A mis-merge corrupts a result and Halts
  with the check number. }
program optcrossjump_correct_01;
{$mode objfpc}

var
  g1, g2, g3, g4: longint;

function classify(x: longint): longint; noinline;
begin
  g1 := 0; g2 := 0; g3 := 0; g4 := 0;
  if x < 0 then
    begin g1 := $0A0B0C0D; g2 := x * 2; g3 := g2 + g1; g4 := g3 xor 7; Exit(g4); end;
  if x = 0 then
    begin g1 := $0A0B0C0D; g2 := x * 2; g3 := g2 + g1; g4 := g3 xor 7; Exit(g4); end;
  if x < 10 then
    begin g1 := $0A0B0C0D; g2 := x * 2; g3 := g2 + g1; g4 := g3 xor 7; Exit(g4); end;
  g1 := $0A0B0C0D; g2 := x * 2; g3 := g2 + g1; g4 := g3 xor 7;
  Result := g4;
end;

function expected(x: longint): longint;
var
  a, b, c, d: longint;
begin
  a := $0A0B0C0D; b := x * 2; c := b + a; d := c xor 7;
  Result := d;
end;

var
  i, got, want: longint;
begin
  for i := -5 to 15 do
    begin
      got := classify(i);
      want := expected(i);
      if got <> want then Halt(1);
      if g4 <> want then Halt(2);
      if g1 <> $0A0B0C0D then Halt(3);
    end;
  Writeln('OK');
end.
