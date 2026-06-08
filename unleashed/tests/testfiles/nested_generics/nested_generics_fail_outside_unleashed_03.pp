{ %FAIL }
{ outside unleashed, a generic declared inside another generic stays
  rejected by the parser. this test compiles deliberately to fail, to
  keep the gate visible }
program nested_generics_fail_outside_unleashed_03;
{$mode objfpc}{$H+}

type
  generic TBox<T>=class
    generic procedure Foo<U>(const a: T; const b: U);
  end;

begin
end.
