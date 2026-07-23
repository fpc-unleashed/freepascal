program inline_vars_u64_const_fold_inference_01;

{$mode unleashed}

// a qword operand combined with a folded constant of qword-cast operands
// typechecks as int64 (the folded value fits int64 and loses the unsigned
// def), but inference goes back to qword like it does for a direct qword
// cast of the same value

const
  CDIRECT = QWord(8358680908399640578);
  CPROD = QWord(2) * QWord(4179340454199820289);
  CSHL = QWord(1) shl 62;

var
  u: QWord = QWord(1) shl 62;

begin
  var a := u + CDIRECT;
  if SizeOf(a) <> 8 then halt(1);
  if a <> QWord(12970366926827028482) then halt(2);

  var b := u + CPROD;
  if SizeOf(b) <> 8 then halt(3);
  if b <> QWord(12970366926827028482) then halt(4);

  // unsigned through comparison: sign-extended int64 would be negative
  if not (b > 0) then halt(5);

  var c := u + CSHL;
  if SizeOf(c) <> 8 then halt(6);
  if c <> QWord(9223372036854775808) then halt(7);
end.
