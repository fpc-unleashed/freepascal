program labels_degenerate_range_01;

{$mode unleashed}

{ N..N declares exactly one label with index N - the explicit form for a
  single-element family }

label foo[256..256];

begin
  goto foo[256];
  halt(1);
  foo[256]:
  halt(0);
end.
