program inline_static_recursive_init_07;
{$mode unleashed}

function Foo(n: Integer): Integer; forward;

function ComputeInitial(n: Integer): Integer;
begin
  if n > 0 then
    Result := Foo(n - 1) * 2
  else
    Result := 1;
end;

function Foo(n: Integer): Integer;
begin
  // recursive: ComputeInitial calls Foo while cache is still uninitialised;
  // guard is set before eval, so nested Foo sees cache=0 and we converge
  // deterministically with cache := 4 after first Foo(3) finishes
  static cache := ComputeInitial(n);
  Result := cache + n;
end;

begin
  if Foo(3) <> 7 then halt(1);
  // cache is already 4 from first call, second invocation just adds n
  if Foo(5) <> 9 then halt(2);
end.
