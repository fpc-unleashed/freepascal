program zeroinit_block_scoped_with_var_14;

{$mode unleashed}

type
  TPoint = record
    x, y: Integer;
  end;

procedure DirtyStack;
var
  a: array[0..15] of Integer;
  i: Integer;
begin
  for i := 0 to 15 do
    a[i] := 3333 + i;
  if a[0] = 0 then halt(10);
end;

function MakePoint: TPoint;
begin
  result.x := 7;
  result.y := 8;
end;

procedure CheckZero; zeroinit;
begin
  with var p := MakePoint do
    begin
      var t: Integer;
      if t <> 0 then halt(1);
      if p.x <> 7 then halt(2);
    end;
end;

begin
  DirtyStack;
  CheckZero;
end.
