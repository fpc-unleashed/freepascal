program inline_forced_array_of_const_01;
{$mode unleashed}

// variadic array of const is a variant open array; it goes through the same
// address-temp inline path, so High and TVarRec element access both work

function count_inl(const args: array of const): longint; inline;
begin
  Result := High(args) + 1;
end;

function sumint_inl(const args: array of const): longint; inline;
var i: longint;
begin
  Result := 0;
  for i := 0 to High(args) do
    if args[i].VType = vtInteger then
      Result := Result + args[i].VInteger;
end;

function sumint_call(const args: array of const): longint;
var i: longint;
begin
  Result := 0;
  for i := 0 to High(args) do
    if args[i].VType = vtInteger then
      Result := Result + args[i].VInteger;
end;

begin
  if count_inl([1, 'two', 3.0]) <> 3 then Halt(1);
  if count_inl([]) <> 0 then Halt(2);
  if sumint_inl([10, 'x', 20, 30]) <> sumint_call([10, 'x', 20, 30]) then Halt(3);
  if sumint_inl([10, 'x', 20, 30]) <> 60 then Halt(4);
end.
