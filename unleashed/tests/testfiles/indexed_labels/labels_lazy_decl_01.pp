program labels_lazy_decl_01;

{$mode unleashed}

begin
  // unleashed mode: no `label` declaration needed
  goto done;
  WriteLn('skipped');
  halt(2);
done:
  // ok
end.
