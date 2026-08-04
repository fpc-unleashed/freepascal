// delphi-style `is not` and `not in` operators in mode unleashed
// `obj is not T` -> not (obj is T)
// `x not in S`   -> not (x in S)

program is_not_not_in_combined_01;

{$mode unleashed}

type
  tbase = class
  end;

  tfoo = class(tbase)
  end;

  tbar = class(tbase)
  end;

  tfruit = (apple, orange, banana, grape);
  tfruits = set of tfruit;

var
  obj : tbase;
  s   : tfruits;
  i   : longint;

begin
  // is not - matching type
  obj := tfoo.create;
  if obj is not tfoo then halt(1);
  if not (obj is not tbar) then halt(2);
  obj.free;

  // is not - non-matching type
  obj := tbar.create;
  if obj is not tbar then halt(3);
  if not (obj is not tfoo) then halt(4);
  obj.free;

  // not in - element present
  s := [apple, orange];
  if apple not in s then halt(10);
  if orange not in s then halt(11);
  if not (banana not in s) then halt(12);
  if not (grape not in s) then halt(13);

  // not in - empty set
  s := [];
  if not (apple not in s) then halt(20);

  // not in - integer range literal
  i := 5;
  if i not in [1..10] then halt(30);
  if not (i not in [20..30]) then halt(31);

  // combined in conditional
  obj := tbar.create;
  if obj is not tfoo then
    s := [apple]
  else
    halt(40);
  obj.free;

  if banana not in s then
    i := 1
  else
    halt(41);

  // ensure plain `is` and `in` still parse normally
  obj := tfoo.create;
  if not (obj is tfoo) then halt(50);
  obj.free;
  if not (apple in [apple, orange]) then halt(51);
end.
