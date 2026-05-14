program anon_capture_for_loop_var_01;

{$mode unleashed}

type
  TIntFn = reference to function: Integer;

var
  fns: array of TIntFn = nil;
  capture_n: Integer;

begin
  // build closures over an enclosing var that mutates per iteration
  for var i := 1 to 3 do
  begin
    capture_n := i * 10;
    fns := fns + [function: Integer
                  begin
                    Result := capture_n;
                  end];
  end;
  // all closures share the same captured var; final value wins
  if Length(fns) <> 3 then halt(1);
  if fns[0]() <> 30 then halt(2);
  if fns[1]() <> 30 then halt(3);
  if fns[2]() <> 30 then halt(4);
end.
