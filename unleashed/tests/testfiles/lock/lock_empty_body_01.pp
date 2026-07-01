program lock_empty_body_01;
{$mode unleashed}

// an empty body is valid (a bare acquire/release fence) and must compile
// without an unused-exception-frame artifact - the lowering skips the
// try-finally when the body has no code
var
  counter: Integer;

begin
  counter := 0;
  lock do;
  lock do begin end;
  lock(counter) do;
  trylock do else Halt(1);            // acquired -> empty body, else skipped
  trylock wait 0 do else Halt(2);
  trylock(counter) wait 50 do else Halt(3);
  // proof the locks still work after the empty-body forms
  lock(counter) do Inc(counter);
  if counter <> 1 then Halt(4);
end.
