{ a generic class can declare a generic method with its own type
  parameter list. specializing the parent class produces a class whose
  method is still a generic template; specializing the method picks its
  own type parameter independently from the class T }
program nested_generics_method_call_01;
{$mode unleashed}

type
  TBox<T>=class(TObject)
    FValue: T;
    FU: Integer;
    procedure Foo<U>(const a: T; const b: U);
  end;

procedure TBox<T>.Foo<U>(const a: T; const b: U);
begin
  FValue := a;
  FU := SizeOf(U);
end;

type
  TFoo = class end;
  TBoxFoo = TBox<TFoo>;

var
  bf: TBoxFoo;
  f: TFoo;
begin
  f := TFoo.Create;
  bf := TBoxFoo.Create;
  bf.Foo<Integer>(f, 42);
  if bf.FValue <> f then Halt(1);
  if bf.FU <> SizeOf(Integer) then Halt(2);
  bf.Foo<Byte>(f, 7);
  if bf.FU <> SizeOf(Byte) then Halt(3);
  bf.Free;
  f.Free;
end.
