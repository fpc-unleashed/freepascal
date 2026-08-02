program inline_forced_inline_off_toggle_01;
{$mode unleashed}

// the switch is read at the declaration, so it selects the regime per
// routine: Early is declared while inlining is off (stock hint), Late after
// it was turned back on (forced)

{$inline off}
function Early(x: Integer): Integer; inline;
begin
  Result := x * 2;
end;

{$inline on}
function Late(x: Integer): Integer; inline;
begin
  Result := x * 3;
end;

begin
  if Early(21) <> 42 then Halt(1);
  if Late(14) <> 42 then Halt(2);
end.
