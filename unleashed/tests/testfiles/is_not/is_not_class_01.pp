program is_not_class_01;

{$mode unleashed}

type
  TBase = class end;
  TDerived = class(TBase) end;
  TOther = class(TBase) end;

var
  b, d, o: TBase;

begin
  b := autofree TBase.Create;
  d := autofree TDerived.Create;
  o := autofree TOther.Create;

  if b is not TBase    then halt(1);
  if d is not TBase    then halt(2);
  if o is not TBase    then halt(3);
  if d is not TDerived then halt(4);
  if not (o is not TDerived) then halt(5);
  if not (b is not TDerived) then halt(6);
end.
