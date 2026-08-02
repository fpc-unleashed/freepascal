program inline_forced_open_array_constructor_01;
{$mode unleashed}

// open array fed an array constructor literal, mixed with other calls in the
// same routine (array constructors keep the normal value path, not addr temp)

function sum_inl(const a: array of longint): longint; inline;
var i: longint;
begin
  Result := 0;
  for i := 0 to High(a) do Result := Result + a[i];
end;

function sum_call(const a: array of longint): longint;
var i: longint;
begin
  Result := 0;
  for i := 0 to High(a) do Result := Result + a[i];
end;

var
  d: array of longint;
begin
  SetLength(d, 3); d[0] := 1; d[1] := 2; d[2] := 3;
  // interleave a dynamic-array inline before the literal to exercise temp reuse
  if sum_inl(d) <> sum_call(d) then Halt(1);
  if sum_inl([100, 200, 300]) <> sum_call([100, 200, 300]) then Halt(2);
  if sum_inl([100, 200, 300]) <> 600 then Halt(3);
end.
