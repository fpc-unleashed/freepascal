{ %OPT=-O2 }
program meminline_side_effects_04;
{$mode unleashed}

// operand expressions with side effects are evaluated exactly once,
// same as when the RTL call takes the address

var
  effects: Integer = 0;
  a, b: array[32] of Byte;

function BumpZero: Integer;
begin
  Inc(effects);
  result := 0;
end;

begin
  FillChar(a, SizeOf(a), $11);
  effects := 0;
  FillChar(a[BumpZero()], 8, $55);
  if effects <> 1 then Halt(10);
  for var i := 0 to 7 do if a[i] <> $55 then Halt(11);
  for var i := 8 to 31 do if a[i] <> $11 then Halt(12);

  FillChar(a, SizeOf(a), $22);
  FillChar(b, SizeOf(b), $99);
  effects := 0;
  Move(a[BumpZero()], b[BumpZero()], 16);
  if effects <> 2 then Halt(20);
  for var i := 0 to 15 do if b[i] <> $22 then Halt(21);
  for var i := 16 to 31 do if b[i] <> $99 then Halt(22);
end.
