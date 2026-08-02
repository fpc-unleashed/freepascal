program inline_forced_open_array_byvalue_01;
{$mode unleashed}

// a by-value open array that is only read: the constructor literal is
// inserted directly, other sources alias the caller's data; a value-temp of
// the open-array type (unknown size) must never be created

function sum_inl(a: array of integer): integer; inline;
begin
  Result := 0;
  for var i := 0 to high(a) do Result := Result + a[i];
end;

function sum_call(a: array of integer): integer;
begin
  Result := 0;
  for var i := 0 to high(a) do Result := Result + a[i];
end;

var
  d: array of integer;
  f: array[1..4] of integer;
  i: integer;
begin
  if sum_inl([1, 2, 3, 999]) <> sum_call([1, 2, 3, 999]) then Halt(1);
  if sum_inl([1, 2, 3, 999]) <> 1005 then Halt(2);
  SetLength(d, 3); for i := 0 to 2 do d[i] := i + 1;
  if sum_inl(d) <> 6 then Halt(3);
  for i := 1 to 4 do f[i] := i * 10;
  if sum_inl(f) <> 100 then Halt(4);
end.
