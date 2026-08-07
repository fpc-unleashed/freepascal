program prepostincdec_generic_08;
{$mode unleashed}

function bumpdown<T>(var v: T): T;
begin
  result := PostDec(v);
end;

function bumpup<T>(var v: T): T;
begin
  result := PreInc(v, 2);
end;

var
  w: Word;
  i: Int64;
begin
  w := 9;
  if bumpdown<Word>(w) <> 9 then halt(1);
  if w <> 8 then halt(2);
  i := -5;
  if bumpdown<Int64>(i) <> -5 then halt(3);
  if i <> -6 then halt(4);
  if bumpup<Int64>(i) <> -4 then halt(5);
end.
