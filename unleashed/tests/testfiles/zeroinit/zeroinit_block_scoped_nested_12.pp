program zeroinit_block_scoped_nested_12;

{$mode unleashed}

procedure DirtyStack;
var
  a: array[0..15] of Integer;
  i: Integer;
begin
  for i := 0 to 15 do
    a[i] := 1111 + i;
  if a[0] = 0 then halt(10);
end;

procedure CheckZero; zeroinit;
begin
  begin
    var i: Integer;
    var j: Integer;
    if i <> 0 then halt(1);
    if j <> 0 then halt(2);
    begin
      var k: Integer;
      if k <> 0 then halt(3);
    end;
  end;
end;

begin
  DirtyStack;
  CheckZero;
end.
