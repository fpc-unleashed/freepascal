program zeroinit_anonymous_compound_08;

{$mode unleashed}

procedure DirtyStack;
var
  arr: array[0..3] of Integer;
  rec: record a, b: Integer; end;
  i: Integer;
begin
  for i := 0 to 3 do
    arr[i] := 99;
  rec.a := 111;
  rec.b := 222;
  if arr[0]+rec.a+rec.b = 0 then halt(10);
end;

// anonymous compound types (no named alias) are zeroed too
procedure CheckZero; zeroinit;
var
  arr: array[0..3] of Integer;
  rec: record a, b: Integer; end;
  i: Integer;
begin
  for i := 0 to 3 do
    if arr[i] <> 0 then halt(1);
  if rec.a <> 0 then halt(2);
  if rec.b <> 0 then halt(3);
end;

begin
  DirtyStack;
  CheckZero;
end.
