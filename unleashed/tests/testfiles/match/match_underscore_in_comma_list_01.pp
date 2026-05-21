program match_underscore_in_comma_list_01;
{$mode unleashed}

// `_` may appear as the LAST element in a comma-separated pattern list;
// the whole branch then collapses to catch-all (else). `_` in any other
// position is rejected (see %FAIL companion tests).
var
  s: string;
  d: string;
begin
  s := 'x';
  d := match s of
    'x': '1';
    'w', 'a', _: '2';
  end;
  if d <> '1' then Halt(1);

  s := 'a';
  d := match s of
    'x': '1';
    'w', 'a', _: '2';
  end;
  if d <> '2' then Halt(2);

  // hits the `_` portion (everything else)
  s := 'zzz';
  d := match s of
    'x': '1';
    'w', 'a', _: '2';
  end;
  if d <> '2' then Halt(3);

  // also works in fallthrough mode
  var n: Integer := 0;
  match all 5 of
    5: Inc(n, 10);
    1, 2, _: Inc(n);
  end;
  if n <> 11 then Halt(4);
end.
