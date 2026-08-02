{ %OPT=-O2 }
program meminline_runtime_value_08;
{$mode unleashed}

// a runtime fill value is replicated across 64 bits with one multiply and
// then stored like a constant one; the value expression runs exactly once

var
  g: record pre: QWord; data: array[64] of Byte; post: QWord; end;
  effects: Integer = 0;

function BumpVal: Byte;
begin
  Inc(effects);
  result := $5C;
end;

procedure CheckFill(n: Integer; v: Byte; code: Integer);
begin
  for var i := 0 to n - 1 do if g.data[i] <> v then Halt(code);
  for var i := n to 63 do if g.data[i] <> 0 then Halt(code + 1);
  if (g.pre <> QWord($AAAAAAAAAAAAAAAA)) or (g.post <> QWord($AAAAAAAAAAAAAAAA)) then Halt(code + 2);
end;

var
  bv: Byte;
  cv: AnsiChar;
  wv: Word;
  dv: DWord;
  qv: QWord;

begin
  g.pre := QWord($AAAAAAAAAAAAAAAA); g.post := g.pre;
  bv := $A7;
  FillChar(g.data, SizeOf(g.data), 0); FillChar(g.data, 1, bv); CheckFill(1, bv, 10);
  FillChar(g.data, SizeOf(g.data), 0); FillChar(g.data, 3, bv); CheckFill(3, bv, 20);
  FillChar(g.data, SizeOf(g.data), 0); FillChar(g.data, 7, bv); CheckFill(7, bv, 30);
  FillChar(g.data, SizeOf(g.data), 0); FillChar(g.data, 8, bv); CheckFill(8, bv, 40);
  FillChar(g.data, SizeOf(g.data), 0); FillChar(g.data, 15, bv); CheckFill(15, bv, 50);
  FillChar(g.data, SizeOf(g.data), 0); FillChar(g.data, 33, bv); CheckFill(33, bv, 60);
  FillChar(g.data, SizeOf(g.data), 0); FillChar(g.data, 64, bv); CheckFill(64, bv, 70);

  cv := 'Z';
  FillChar(g.data, SizeOf(g.data), 0);
  FillChar(g.data, 5, cv);
  CheckFill(5, Ord('Z'), 80);

  wv := $BEEF;
  FillWord(g.data, 7, wv);
  for var i := 0 to 6 do if PWord(@g.data[0])[i] <> $BEEF then Halt(90);

  dv := $DEADBEEF;
  FillDWord(g.data, 5, dv);
  for var i := 0 to 4 do if PDWord(@g.data[0])[i] <> $DEADBEEF then Halt(100);

  qv := QWord($0123456789ABCDEF);
  FillQWord(g.data, 4, qv);
  for var i := 0 to 3 do if PQWord(@g.data[0])[i] <> qv then Halt(110);

  // value expression side effect runs once
  effects := 0;
  FillChar(g.data, 16, BumpVal());
  if effects <> 1 then Halt(120);
  for var i := 0 to 15 do if g.data[i] <> $5C then Halt(121);
end.
