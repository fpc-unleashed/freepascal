program prepostincdec_shadow_10;
{$mode unleashed}

// a user-declared symbol takes over, the builtin steps aside
function PostInc(var q: Integer): Integer;
begin
  inc(q, 1000);
  result := -1;
end;

var
  a: Integer;
begin
  a := 5;
  if PostInc(a) <> -1 then halt(1);
  if a <> 1005 then halt(2);
  // the other three still resolve to the builtins
  if PreInc(a) <> 1006 then halt(3);
  if PostDec(a) <> 1006 then halt(4);
  if PreDec(a) <> 1004 then halt(5);
end.
