{ %OPT="-O4" }
{ Case arms that end with a common cleanup/epilogue.  Each arm seeds acc
  differently but the trailing "acc := acc*2; acc := acc+5; <join>" is
  identical across arms; cross-jumping keeps one copy and redirects the
  others.  Every arm (and the else) must still yield the right value. }
program optcrossjump_casecleanup_01;
{$mode objfpc}

function h(x: longint): longint; noinline;
var
  acc: longint;
begin
  acc := 0;
  case x of
    1: begin acc := 10; acc := acc * 2; acc := acc + 5; end;
    2: begin acc := 20; acc := acc * 2; acc := acc + 5; end;
    3: begin acc := 30; acc := acc * 2; acc := acc + 5; end;
    4: begin acc := 40; acc := acc * 2; acc := acc + 5; end;
  else
    acc := 99;
  end;
  Result := acc;
end;

begin
  if h(1) <> 25 then Halt(1);
  if h(2) <> 45 then Halt(2);
  if h(3) <> 65 then Halt(3);
  if h(4) <> 85 then Halt(4);
  if h(7) <> 99 then Halt(5);
  if h(0) <> 99 then Halt(6);
  Writeln('OK');
end.
