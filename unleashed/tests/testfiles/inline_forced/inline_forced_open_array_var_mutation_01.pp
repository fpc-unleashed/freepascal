program inline_forced_open_array_var_mutation_01;
{$mode unleashed}

// var open array: writes through the inlined body must reach the caller's array

procedure dbl_inl(var a: array of longint); inline;
var i: longint;
begin
  for i := 0 to High(a) do a[i] := a[i] * 2;
end;

var
  f: array[1..5] of longint;
  i: longint;
begin
  for i := 1 to 5 do f[i] := i;
  dbl_inl(f);
  for i := 1 to 5 do
    if f[i] <> i * 2 then Halt(1);
end.
