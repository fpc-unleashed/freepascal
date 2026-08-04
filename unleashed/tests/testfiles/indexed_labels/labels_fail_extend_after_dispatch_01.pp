{ %FAIL }
program labels_fail_extend_after_dispatch_01;

{$mode unleashed}

{ A variable-index goto bakes its dispatch from the range declared at that
  point. Labels added afterwards (lazily) lie outside that range and could
  never be reached through the dispatch, so the compiler must reject them
  instead of producing silently unreachable targets. }

procedure Broken(i: byte);
label state[4..4];  // degenerate range: declares only state[4]
begin
  goto state[i];  // dispatch frozen over {4}
  state[0]: writeln(0); exit;   // outside the frozen range -> error
  state[1]: writeln(1); exit;
  state[2]: writeln(2); exit;
  state[3]: writeln(3); exit;
end;

begin
  Broken(0);
end.
