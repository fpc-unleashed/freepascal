{ unleashed: inline `array of X` / `packed array ...` / `bitpacked array ...`
  is accepted as a function result type and assigned-into / iterated like
  any other array }
program array_result_forms_01;

{$mode unleashed}

function dynstr: array of string;
begin
  Result := ['aa', 'bb', 'cc'];
end;

function staticint: array[0..2] of integer;
begin
  Result[0] := 10;
  Result[1] := 20;
  Result[2] := 30;
end;

function packedbytes: packed array[0..3] of byte;
begin
  Result[0] := 1;
  Result[1] := 2;
  Result[2] := 3;
  Result[3] := 4;
end;

function bitpackedbits: bitpacked array[0..2] of boolean;
begin
  Result[0] := true;
  Result[1] := false;
  Result[2] := true;
end;

var
  s: array of string;
  si: array[0..2] of integer;
  b: packed array[0..3] of byte;
  bb: bitpacked array[0..2] of boolean;
begin
  s := dynstr;
  if Length(s) <> 3 then Halt(1);
  if s[0] <> 'aa' then Halt(2);
  if s[2] <> 'cc' then Halt(3);

  si := staticint;
  if si[0] <> 10 then Halt(4);
  if si[2] <> 30 then Halt(5);

  b := packedbytes;
  if b[0] <> 1 then Halt(6);
  if b[3] <> 4 then Halt(7);

  bb := bitpackedbits;
  if not bb[0] then Halt(8);
  if bb[1] then Halt(9);
  if not bb[2] then Halt(10);
end.
