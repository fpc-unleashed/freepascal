program inline_forced_block_var_double_expand_01;
{$mode unleashed}

// a block-scoped inline var (for var i) inside an inlined body must get a
// fresh temp per expansion; sharing the symbol's standalone frame location
// corrupted the second expansion (it read another temp's data)

function sum_inl(a: array of integer): integer; inline;
begin
  Result := 0;
  for var i := 0 to high(a) do Result := Result + a[i];
end;

var
  x, y: integer;
begin
  x := sum_inl([1, 2, 3, 999]);
  y := sum_inl([1, 2, 3, 999]);
  if x <> 1005 then Halt(1);
  if y <> 1005 then Halt(2);
end.
