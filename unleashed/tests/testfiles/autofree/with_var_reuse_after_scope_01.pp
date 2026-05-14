program with_var_reuse_after_scope_01;

{$mode unleashed}

type
  TPoint = record
    a, b: Integer;
  end;

// historic regression: after a `with var p := ...` block ends, the name `p`
// must be released so a sibling `with var p := ...` further down can declare
// it again. Earlier the variable stayed bound and the second declaration
// failed.

begin
  with var p: TPoint := (a: 1; b: 2) do
    if p.a <> 1 then halt(1);

  // a sibling with-scope must be allowed to reuse the same name
  with var p: TPoint := (a: 10; b: 20) do
    if p.a <> 10 then halt(2);
end.
