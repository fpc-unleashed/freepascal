program type_intrinsic_cast_04;

{$mode unleashed}

var
  x: Integer;
  b: Byte;
  s: Single;
  d: Double;
  r: Integer;
  rs: Single;
begin
  x := 100;
  b := 7;
  // cast literal to type of x (Integer)
  r := Type(x)(b);
  if r <> 7 then Halt(1);

  s := 3.5;
  // cast Double via Type(s) which is Single
  d := 7.25;
  rs := Type(s)(d);
  if rs <> 7.25 then Halt(2);
end.
