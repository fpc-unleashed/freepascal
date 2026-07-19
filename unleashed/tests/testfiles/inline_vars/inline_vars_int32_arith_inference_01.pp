program inline_vars_int32_arith_inference_01;

{$mode unleashed}
{$R-}
{$Q-}

var
  a: DWord = $FFFFFFFF;
  b: DWord = 1;
  si: LongInt = -5;
  sj: LongInt = 7;
begin
  // unsigned 32-bit arithmetic infers a 4-byte type on every target,
  // so the wrap-around carry idiom `s < a` keeps working on 64-bit CPUs
  var s := a + b;
  if SizeOf(s) <> 4 then halt(1);
  if s <> 0 then halt(2);
  if not (s < a) then halt(3);

  // signed stays 32-bit signed
  var t := si + sj;
  if SizeOf(t) <> 4 then halt(4);
  if t <> 2 then halt(5);

  // mixed sign widens to 64 bit, same as 32-bit natives
  var m := a + si;
  if SizeOf(m) <> 8 then halt(6);

  // unsigned subtraction widens to 64 bit, same as 32-bit natives
  var d := b - a;
  if SizeOf(d) <> 8 then halt(7);

  // explicit cast keeps the 64-bit type
  var q := QWord(a) + b;
  if SizeOf(q) <> 8 then halt(8);
  if q <> $100000000 then halt(9);

  // truncating multiply matches 32-bit natives
  var p := a * a;
  if SizeOf(p) <> 4 then halt(10);
  if p <> 1 then halt(11);

  // negation of unsigned demotes to 32-bit signed
  var n := -a;
  if SizeOf(n) <> 4 then halt(12);
end.
