program out_var_var_param_inline_01;
{$mode unleashed}

// zero/seed initialization survives inlining of the callee
// and of a caller that contains the declaration
procedure accIn(var a: integer; n: integer); inline;
begin
  a := a + n;
end;

function useIt: integer; inline;
begin
  accIn(var t := 3, 4);
  result := t;
end;

begin
  accIn(var x := 1, 2);
  if x <> 3 then Halt(1);
  if useIt <> 7 then Halt(2);
end.
