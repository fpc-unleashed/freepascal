program inline_forced_open_array_dynamic_01;
{$mode unleashed}

// open array fed a dynamic array: the spliced body must index it through the
// open-array representation (an address temp), not value-copy it

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
  i: longint;
begin
  SetLength(d, 6);
  for i := 0 to 5 do d[i] := i + 1;
  if sum_inl(d) <> sum_call(d) then Halt(1);
  if sum_inl(d) <> 21 then Halt(2);
end.
