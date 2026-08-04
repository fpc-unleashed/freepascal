{ composablerecords: calling a generic method via `inst.specialize M<T>` on a
  record-typed expression must not AV. regression: compose_chain was only nil-
  initialised on the non-specialize branch of postfixoperators, so the later
  assigned(compose_chain) check could read garbage and try to walk it. }
program composable_records_specialize_member_call_01;

{$mode objfpc}{$h+}
{$modeswitch advancedrecords}

type
  TInner = record
  public
    generic function AsType<T>: T;
  end;

  TOuter = class
  public
    generic function AsType<T>: T;
  end;

generic function TInner.AsType<T>: T;
begin
  Result := Default(T);
end;

generic function TOuter.AsType<T>: T;
var
  v: TInner;
begin
  Result := v.specialize AsType<T>;
end;

var
  b: TOuter;
begin
  b := TOuter.Create;
  if b.specialize AsType<integer> <> 0 then Halt(1);
  b.Free;
end.
