program inline_forced_open_array_nonzero_base_01;
{$mode unleashed}

// open array fed an array[1..10]: the index must be re-based to 0, which the
// restored open-array view handles (this was the classic worry blocking inline)

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
  f: array[1..10] of longint;
  i: longint;
begin
  for i := 1 to 10 do f[i] := i;
  if sum_inl(f) <> sum_call(f) then Halt(1);
  if sum_inl(f) <> 55 then Halt(2);
end.
