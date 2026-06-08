{ a generic method body that calls TypeInfo(T) depends on
  the concrete type identity of T - not just its ABI shape. the
  compiler must fall back to monomorphization for every specialization
  of such a method, otherwise the shared body would return the
  TypeInfo of whichever specialization happened to be compiled first }
program lightgenerics_typeinfo_fallback_13;
{$mode unleashed}
{$modeswitch lightgenerics}

uses TypInfo;

type
  TBox<T>=class(TObject)
    FValue: T;
    function TypeName: ShortString;
  end;

function TBox<T>.TypeName: ShortString;
begin
  Result := PTypeInfo(TypeInfo(T))^.Name;
end;

type
  TFoo = class end;
  TBar = class end;
  TBoxFoo = TBox<TFoo>;
  TBoxBar = TBox<TBar>;

var
  bf: TBoxFoo;
  bb: TBoxBar;
begin
  bf := TBoxFoo.Create;
  bb := TBoxBar.Create;
  if bf.TypeName <> 'TFoo' then Halt(1);
  if bb.TypeName <> 'TBar' then Halt(2);
  bf.Free;
  bb.Free;
end.
