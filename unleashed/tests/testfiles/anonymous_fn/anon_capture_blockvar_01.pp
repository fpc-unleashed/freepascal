program anon_capture_blockvar_01;

{$mode unleashed}

{ regression: closure captures an inline-var declared inside a
  `begin..end` block scope. when the outer procedure had another
  block-scope inline-var earlier, the closure's view of the captured
  variable was unsynchronized - it read uninitialized memory and writes
  to it never reached the outer's slot }

type
  TFn = reference to function: Boolean;

procedure main;
begin
  begin
    var c := 0;
    if c <> 0 then halt(99);
  end;

  begin
    var c2 := 0;
    var f: TFn := function: Boolean
                  begin
                    if c2 <> 0 then halt(1);
                    c2 += 1;
                    if c2 <> 1 then halt(2);
                    result := false;
                  end;
    f();
    if c2 <> 1 then halt(3);
  end;
end;

begin
  main;
end.
