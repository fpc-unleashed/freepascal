program match_all_otherwise_no_match_01;

{$mode unleashed}

var
  s: String;
  hits, fallback: Integer;

begin
  // string subject, a branch matched: otherwise must not run
  s := 'foo';
  hits := 0;
  fallback := 0;
  match all s of
    'foo': Inc(hits);
    'bar': Inc(hits);
    otherwise Inc(fallback);
  end;
  if hits <> 1 then halt(1);
  if fallback <> 0 then halt(2);

  // nothing matched: otherwise runs once
  s := 'baz';
  hits := 0;
  fallback := 0;
  match all s of
    'foo': Inc(hits);
    'bar': Inc(hits);
    otherwise Inc(fallback);
  end;
  if hits <> 0 then halt(3);
  if fallback <> 1 then halt(4);
end.
