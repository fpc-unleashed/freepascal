program type_intrinsic_derived_types_06;

{$mode unleashed}

var
  x: Integer;
  s: AnsiString;

  arr: array of Type(x);
  parr: ^Type(x);

  sarr: array of Type(s);
  i: Integer;
  v: Integer;
begin
  SetLength(arr, 3);
  arr[0] := 10; arr[1] := 20; arr[2] := 30;
  v := 0;
  for i := 0 to High(arr) do Inc(v, arr[i]);
  if v <> 60 then Halt(1);

  New(parr);
  parr^ := 555;
  if parr^ <> 555 then Halt(2);
  Dispose(parr);

  SetLength(sarr, 2);
  sarr[0] := 'hello';
  sarr[1] := 'world';
  if sarr[0] + ' ' + sarr[1] <> 'hello world' then Halt(3);
end.
