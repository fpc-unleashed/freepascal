{ %OPT=-O2 }
program inline_vars_in_inlined_routine_02;

{$mode unleashed}

// when inline info is created, block-scoped locals are re-homed into the
// routine's localst so the stored node tree can resolve them; two sibling
// for-blocks reusing the counter name plus a nested block var cover the
// duplicate-name path

function SumRange(n: Int64): Int64; inline;
begin
  result := 0;
  for var i := 1 to n do
    begin
      var doubled := i * 2;
      inc(result, doubled);
    end;
  for var i := 1 to 2 do
    dec(result, i);
end;

procedure Driver;
begin
  // 2+4+6+8 - (1+2)
  if SumRange(4) <> 17 then Halt(1);
  if SumRange(0) <> -3 then Halt(2);
end;

begin
  Driver;
end.
