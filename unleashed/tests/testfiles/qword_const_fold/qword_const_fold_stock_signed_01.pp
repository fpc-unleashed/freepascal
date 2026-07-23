program qword_const_fold_stock_signed_01;

{$mode objfpc}

// outside unleashed the folded constant stays value-typed (int64 here),
// so the sum evaluates signed; guards against the unleashed fold typing
// leaking into stock modes

const
  CPROD = QWord(2) * QWord(4179340454199820289);

var
  u: QWord = QWord(1) shl 62;

begin
  if not (u + CPROD < 0) then halt(1);
end.
