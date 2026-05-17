{ empty `match end` as a statement compiles to a no-op, like `begin end` or
  `case X of end`; previously rejected with "Illegal expression" because the
  parser eagerly tried to parse a condition expression after `match` }
program tb9005;

{$mode unleashed}

procedure use_match;
begin
  match end;            { truly empty, no condition }
  match all end;        { fallthrough variant, also empty }
  match true: ; end;    { single dummy branch, still works }
end;

begin
  use_match;
end.
