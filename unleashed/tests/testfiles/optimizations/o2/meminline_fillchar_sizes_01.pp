{ %OPT=-O2 }
program meminline_fillchar_sizes_01;
{$mode unleashed}

// constant-count FillChar is expanded into direct stores; verify every
// inlined size plus sizes beyond the expansion cap, with guard zones
// around the payload to catch overruns

type
  TGuarded = record
    guard1: array[16] of Byte;
    data: array[128] of Byte;
    guard2: array[16] of Byte;
  end;

var g: TGuarded;

procedure InitGuards;
begin
  FillChar(g, SizeOf(g), $CC);
  for var i := 0 to 127 do g.data[i] := $77;
end;

procedure CheckState(n: Integer; code: Integer);
begin
  for var i := 0 to 15 do if (g.guard1[i] <> $CC) or (g.guard2[i] <> $CC) then Halt(code);
  for var i := 0 to n - 1 do if g.data[i] <> $A5 then Halt(code + 1);
  for var i := n to 127 do if g.data[i] <> $77 then Halt(code + 2);
end;

begin
  InitGuards; FillChar(g.data, 1, $A5); CheckState(1, 10);
  InitGuards; FillChar(g.data, 2, $A5); CheckState(2, 20);
  InitGuards; FillChar(g.data, 3, $A5); CheckState(3, 30);
  InitGuards; FillChar(g.data, 4, $A5); CheckState(4, 40);
  InitGuards; FillChar(g.data, 5, $A5); CheckState(5, 50);
  InitGuards; FillChar(g.data, 6, $A5); CheckState(6, 60);
  InitGuards; FillChar(g.data, 7, $A5); CheckState(7, 70);
  InitGuards; FillChar(g.data, 8, $A5); CheckState(8, 80);
  InitGuards; FillChar(g.data, 9, $A5); CheckState(9, 90);
  InitGuards; FillChar(g.data, 15, $A5); CheckState(15, 100);
  InitGuards; FillChar(g.data, 16, $A5); CheckState(16, 110);
  InitGuards; FillChar(g.data, 17, $A5); CheckState(17, 120);
  InitGuards; FillChar(g.data, 24, $A5); CheckState(24, 130);
  InitGuards; FillChar(g.data, 31, $A5); CheckState(31, 140);
  InitGuards; FillChar(g.data, 32, $A5); CheckState(32, 150);
  InitGuards; FillChar(g.data, 33, $A5); CheckState(33, 160);
  InitGuards; FillChar(g.data, 63, $A5); CheckState(63, 170);
  InitGuards; FillChar(g.data, 64, $A5); CheckState(64, 180);
  InitGuards; FillChar(g.data, 65, $A5); CheckState(65, 190);
  // char and boolean overloads
  InitGuards; FillChar(g.data, 5, Chr($A5)); CheckState(5, 200);
  InitGuards; FillChar(g.data, 6, true);
  for var i := 0 to 5 do if g.data[i] <> 1 then Halt(210);
  // zero value
  InitGuards; FillChar(g.data, 16, 0);
  for var i := 0 to 15 do if g.data[i] <> 0 then Halt(220);
  for var i := 16 to 127 do if g.data[i] <> $77 then Halt(221);
end.
