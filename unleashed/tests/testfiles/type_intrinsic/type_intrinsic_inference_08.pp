program type_intrinsic_inference_08;

{$mode unleashed}

type
  TPoint = record x, y: Integer; end;

function MakePoint(ax, ay: Integer): TPoint;
begin
  Result.x := ax;
  Result.y := ay;
end;

begin
  // unleashed: inline var, type inferred from the factory call
  var z := MakePoint(3, 4);
  var cache: array of Type(z);
  var scalar: Type(z);

  SetLength(cache, 2);
  cache[0] := MakePoint(10, 20);
  cache[1] := z;
  if (cache[0].x <> 10) or (cache[0].y <> 20) then Halt(1);
  if (cache[1].x <> 3) or (cache[1].y <> 4) then Halt(2);
  scalar.x := 7;
  scalar.y := 8;
  if (scalar.x <> 7) or (scalar.y <> 8) then Halt(3);
end.
