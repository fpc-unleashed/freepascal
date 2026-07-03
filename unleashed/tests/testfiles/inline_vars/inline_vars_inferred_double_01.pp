program inline_vars_inferred_double_01;

{$mode unleashed}

begin
  var pi := 3.14;
  if pi < 3.13 then halt(1);
  if pi > 3.15 then halt(2);
  // float literals infer the platform default real type: Double on 64-bit,
  // Extended (10 bytes) on i386
  {$ifdef CPU64}
  if SizeOf(pi) <> 8 then halt(3);
  {$else}
  if SizeOf(pi) <> 10 then halt(3);
  {$endif}
end.
