program qword_const_fold_unsigned_01;

{$mode unleashed}

// a folded constant expression of qword-cast operands keeps the qword
// type even when the value fits int64, matching a direct qword cast
// of the same value, so arithmetic with it evaluates unsigned

const
  CDIRECT = QWord(8358680908399640578);
  CPROD = QWord(2) * QWord(4179340454199820289);
  CSHL = QWord(1) shl 62;

var
  u: QWord = QWord(1) shl 62;

begin
  if u + CPROD <> QWord(12970366926827028482) then halt(1);
  if u + CPROD <> u + CDIRECT then halt(2);
  if u + CSHL <> QWord(9223372036854775808) then halt(3);
end.
