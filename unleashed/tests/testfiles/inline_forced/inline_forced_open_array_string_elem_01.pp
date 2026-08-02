program inline_forced_open_array_string_elem_01;
{$mode unleashed}

// open array of a managed element type (string)

function totallen_inl(const s: array of string): longint; inline;
var i: longint;
begin
  Result := 0;
  for i := 0 to High(s) do Result := Result + Length(s[i]);
end;

function totallen_call(const s: array of string): longint;
var i: longint;
begin
  Result := 0;
  for i := 0 to High(s) do Result := Result + Length(s[i]);
end;

begin
  if totallen_inl(['a', 'bb', 'ccc']) <> totallen_call(['a', 'bb', 'ccc']) then Halt(1);
  if totallen_inl(['a', 'bb', 'ccc']) <> 6 then Halt(2);
end.
