program defer_in_subprocedure_chain_01;

{$mode unleashed}

var
  trace: String = '';

procedure Inner;
begin
  defer trace := trace + 'inner;';
end;

procedure Middle;
begin
  defer trace := trace + 'middle;';
  Inner;
end;

procedure Outer;
begin
  defer trace := trace + 'outer;';
  Middle;
end;

begin
  Outer;
  // each proc fires its defer when it returns; order: inner first
  // (returns first), then middle, then outer
  if trace <> 'inner;middle;outer;' then halt(1);
end.
