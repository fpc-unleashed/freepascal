program type_intrinsic_field_param_result_12;

{$mode unleashed}

var
  proto: Integer;

type
  TBox = record
    // field: Type(...) on a unit-level type referring to a unit-level var
    val: Type(proto);
  end;

function Identity(v: Type(proto)): Type(proto);
begin
  Result := v;
end;

var
  b: TBox;
  r: Integer;
begin
  b.val := 42;
  r := Identity(b.val);
  if r <> 42 then Halt(1);
  if SizeOf(b.val) <> SizeOf(Integer) then Halt(2);
end.
