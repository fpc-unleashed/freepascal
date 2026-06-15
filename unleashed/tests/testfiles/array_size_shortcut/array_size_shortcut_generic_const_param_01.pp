program array_size_shortcut_generic_const_param_01;

{$mode unleashed}

{ array[N] shorthand where N is a generic const parameter: the bound has no
  value while the generic is parsed, the real range is built per specialization }
type
  TRec<const N: Integer; T> = record
    data: array[N] of T;
  end;

var
  x: TRec<100, Byte>;
  y: TRec<4, LongWord>;
begin
  if Length(x.data) <> 100 then halt(1);
  if SizeOf(x.data) <> 100 then halt(2);
  x.data[0] := 7;
  x.data[99] := 9;
  if x.data[0] <> 7 then halt(3);
  if x.data[99] <> 9 then halt(4);

  if Length(y.data) <> 4 then halt(5);
  if SizeOf(y.data) <> 16 then halt(6);
end.
