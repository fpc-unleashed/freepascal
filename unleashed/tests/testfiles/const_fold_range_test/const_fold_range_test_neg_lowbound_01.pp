{ %OPT=-O2 }
{
  Regression for the cs_opt_level2 const-fold miscompile that made
  pletora/neural-api's neuralvolume.pas uncompilable at -O2/-O3/-O4
  ("neuralvolume.pas(2147,1) Error: Overflow in arithmetic operation").

  Root cause: the level2 range-test optimization rewrites
      (C1 <= expr) and (expr < C2)
  into the unsigned test
      (expr - C1) <= (C2 - C1)
  (nadd.pas, is_range_test). When the lower bound C1 is negative it is
  stored as an nf_internal *unsigned* ordinal constant, e.g. qword(-149)
  = $FFFFFFFFFFFFFF6B. When such a helper is inlined at a call site where
  "expr" folds to a compile-time constant, nadd.pas folds
      0 - qword(-149)
  which sets the tconstexprint overflow flag (0 < $FF..F6B in unsigned
  arithmetic) and raised a spurious user-facing overflow ERROR, even
  though this is intentional modulo-2^n wraparound in compiler-generated
  code. In neural-api this fired inside pcr_powf -> is_exact_pf (whose
  "(-149 <= Trunc(y)*e) and (...)" range test folded once y=1/2.4 made
  Trunc(y)=0), and surfaced at lab2rgb's float "/const" statements.

  Fix: nadd.pas no longer raises parser_e_arithmetic_operation_overflow
  for nf_internal add/sub/mul const-folds; it keeps the wrapped value.

  This test compiles clean at -O1 and FAILS to compile at -O2 with the
  fix reverted. With the fix it compiles and the runtime results below
  confirm the wrapped constant is also numerically correct.
}
program const_fold_range_test_neg_lowbound_01;

{$mode objfpc}
{$INLINE ON}

{ negative lower bound -> level2 rewrites into an unsigned range test
  whose low-bound constant is qword(-149) }
function inrange(a, b: longint): boolean; inline;
begin
  result := (-149 <= a * b) and (a * b < 128);
end;

var
  v: longint;
begin
  { Constant-folded call sites: a*b folds to a compile-time constant
    inside the inlined body -- exactly where "0 - qword(-149)" was
    folded and wrongly reported as an overflow error at -O2. }
  if not inrange(0, 5)    then Halt(1);  { 0   in  [-149,128) }
  if not inrange(1, 100)  then Halt(2);  { 100 in  range }
  if     inrange(2, 100)  then Halt(3);  { 200 out of range (>=128) }
  if not inrange(-1, 149) then Halt(4);  { -149 in range (inclusive low) }
  if     inrange(-1, 150) then Halt(5);  { -150 out of range }

  { Runtime values exercise the transformed unsigned range test itself. }
  v := 0;   if not inrange(v, 7)   then Halt(6);
  v := 50;  if not inrange(v, 2)   then Halt(7);   { 100 in range }
  v := 64;  if     inrange(v, 2)   then Halt(8);   { 128 out of range }
  v := -1;  if not inrange(v, 149) then Halt(9);   { -149 in range }
  v := -1;  if     inrange(v, 150) then Halt(10);  { -150 out of range }

  { fall through -> exit code 0 -> PASS }
end.
