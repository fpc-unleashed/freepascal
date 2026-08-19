program out_var_var_param_discard_zero_01;
{$mode unleashed}

// `_` at a var parameter passes a hidden temp that is zero-initialized,
// so the callee never sees garbage
procedure mustBeZero(var x: integer);
begin
  if x <> 0 then Halt(1);
  x := 7;
end;

procedure mustBeEmpty(var s: string);
begin
  if s <> '' then Halt(2);
  s := 'set';
end;

begin
  mustBeZero(_);
  mustBeEmpty(_);
end.
