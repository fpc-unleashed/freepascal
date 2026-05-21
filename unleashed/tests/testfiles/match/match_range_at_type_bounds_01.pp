program match_range_at_type_bounds_01;
{$mode unleashed}

// range patterns whose lower bound equals the subject type's natural
// minimum (or upper bound equals the maximum) drop the redundant half
// of the range comparison; before this fix the lowering emitted both
// `b >= 0` AND `b <= N` which earned a misleading
// "comparison might be always true" warning on the lower half
var
  b: Byte;
  c: Integer;
begin
  b := 123;
  c := match b of
    0..1: 1;
    20..30: 2;
    _: 3;
  end;
  if c <> 3 then Halt(1);

  // hits the lower-bound-at-min range
  b := 1;
  c := match b of
    0..1: 1;
    _: 0;
  end;
  if c <> 1 then Halt(2);

  // hits the upper-bound-at-max range
  b := 200;
  c := match b of
    100..255: 100;
    _: 0;
  end;
  if c <> 100 then Halt(3);

  // full range = constant true, matches anything
  b := 42;
  c := match b of
    0..255: 1;
    _: 0;
  end;
  if c <> 1 then Halt(4);

  // signed subject: bounds NOT at type min/max, both halves needed
  var i: Integer := 5;
  c := match i of
    1..10: 1;
    _: 0;
  end;
  if c <> 1 then Halt(5);
end.
