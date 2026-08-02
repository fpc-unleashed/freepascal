program inline_forced_local_goto_01;
{$mode unleashed}

// a local goto/label inside a inline body is fine (only non-local gotos
// are rejected); labels are relabeled per expansion like any inline body

function find_inl(const a: array of longint; target: longint): longint; inline;
label found, done;
var i: longint;
begin
  for i := 0 to High(a) do
    if a[i] = target then goto found;
  Result := -1;
  goto done;
found:
  Result := i;
done:
end;

function find_call(const a: array of longint; target: longint): longint;
label found, done;
var i: longint;
begin
  for i := 0 to High(a) do
    if a[i] = target then goto found;
  Result := -1;
  goto done;
found:
  Result := i;
done:
end;

var
  d: array of longint;
  i: longint;
begin
  SetLength(d, 5);
  for i := 0 to 4 do d[i] := i * 10;
  // two expansions in one routine force per-instance label renaming
  for i := -1 to 5 do
    if find_inl(d, i * 10) <> find_call(d, i * 10) then Halt(1);
  if find_inl(d, 30) <> 3 then Halt(2);
  if find_inl(d, 999) <> -1 then Halt(3);
end.
