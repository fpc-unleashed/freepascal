program type_intrinsic_generic_arg_13;

{$mode unleashed}

uses fgl;

var
  proto: Integer;
  // unleashed has implicit-generics so no `specialize` keyword needed
  L: TFPGList<Type(proto)>;
begin
  L := TFPGList<Type(proto)>.Create;
  L.Add(10);
  L.Add(20);
  L.Add(30);
  if L.Count <> 3 then Halt(1);
  if L[1] <> 20 then Halt(2);
  L.Free;
end.
