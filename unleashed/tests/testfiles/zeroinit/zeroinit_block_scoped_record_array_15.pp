program zeroinit_block_scoped_record_array_15;

{$mode unleashed}

type
  TPair = record
    a, b: Integer;
  end;

procedure DirtyStack;
var
  a: array[0..31] of Integer;
  i: Integer;
begin
  for i := 0 to 31 do
    a[i] := 4444 + i;
  if a[0] = 0 then halt(10);
end;

procedure CheckZero; zeroinit;
begin
  begin
    var r: TPair;
    var arr: array[0..7] of Integer;
    var i: Integer;
    if r.a <> 0 then halt(1);
    if r.b <> 0 then halt(2);
    for i := 0 to 7 do
      if arr[i] <> 0 then halt(3);
  end;
end;

begin
  DirtyStack;
  CheckZero;
end.
