program auto_properties_init_inheritance_16;

{$mode unleashed}

// initializers on a base class and a descendant are both applied when the
// descendant is constructed
type
  TBase = class
    property A: Integer = 1;
  end;

  TDerived = class(TBase)
    property B: Integer = 2;
  end;

var
  d: TDerived;
begin
  d := TDerived.Create;
  if d.A <> 1 then halt(1);
  if d.B <> 2 then halt(2);
  d.Free;
end.
