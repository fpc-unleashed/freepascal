program anon_inline_immediate_01;

{$mode unleashed}

type
  TIntFn = reference to function(x: Integer): Integer;

function Apply(f: TIntFn; v: Integer): Integer;
begin
  Result := f(v);
end;

begin
  // anonymous function declared inline at the call site
  var r := Apply(function(x: Integer): Integer
                 begin
                   Result := x * x + 1;
                 end, 6);
  if r <> 37 then halt(1);
end.
