{ %OPT="-O4" }
{ LICM punts on aliasing: a variable whose address is taken may be modified
  through the pointer inside the loop, so it must not be treated as invariant.
  Here width is written via p^ each iteration; a wrong hoist would give 140. }
program licm_addr_taken_alias_01;
{$mode objfpc}

function work(n: longint): longint;
var
  i, row, width, acc: longint;
  p: ^longint;
begin
  row := n + 5;
  width := n + 7;               { starts at 7 }
  p := @width;
  acc := 0;
  for i := 1 to 4 do
    begin
      acc := acc + row * width; { 35+40+45+50 = 170 }
      p^ := p^ + 1;             { modifies width through an alias }
    end;
  work := acc;
end;

begin
  if work(0) <> 170 then Halt(1);
end.
