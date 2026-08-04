{ Aggregate initialisers for inline var: array / record literal
  routed through the typed-const parser. }
{$mode unleashed}
program inline_vars_aggregate_init_01;

type
  TPoint = record
    x, y: integer;
  end;

  TMatrix = array[1..2, 1..2] of integer;

procedure TestAggregates;
begin
  { Scalar - plain expr path, unchanged }
  var n: integer := 42;
  if n <> 42 then Halt(1);

  { Parenthesised scalar - still plain expr path }
  var p: integer := (5 + 3);
  if p <> 8 then Halt(2);

  { Static array of string }
  var a: array[1..3] of string := ('foo', 'bar', 'baz');
  if (a[1] <> 'foo') or (a[2] <> 'bar') or (a[3] <> 'baz') then Halt(3);

  { Static array of integer, zero-based }
  var b: array[0..2] of integer := (10, 20, 30);
  if (b[0] <> 10) or (b[1] <> 20) or (b[2] <> 30) then Halt(4);

  { Static 2D array }
  var m: TMatrix := ((1, 2), (3, 4));
  if (m[1,1] <> 1) or (m[1,2] <> 2) or
     (m[2,1] <> 3) or (m[2,2] <> 4) then Halt(5);

  { Named record type }
  var pt: TPoint := (x: 11; y: 22);
  if (pt.x <> 11) or (pt.y <> 22) then Halt(6);

  { Anonymous record type }
  var r: record u, v: integer; end := (u: 7; v: 9);
  if (r.u <> 7) or (r.v <> 9) then Halt(7);
end;

begin
  TestAggregates;
  WriteLn('OK');
end.
