program with_var_reuse_nested_block_01;

{$mode unleashed}

type
  TPoint = record
    a, b: Integer;
  end;

// nested scope variant of the regression: outer `with var p` wraps a body
// that contains another `with var p` inside it. The inner one must not
// collide with the outer.

begin
  with var p: TPoint := (a: 1; b: 2) do
  begin
    if p.a <> 1 then halt(1);
    with var p: TPoint := (a: 10; b: 20) do
      if p.a <> 10 then halt(2);
    // outer p is back in scope, value unchanged
    if p.a <> 1 then halt(3);
  end;
end.
