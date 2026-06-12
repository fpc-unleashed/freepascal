{ %FAIL }
program type_intrinsic_anon_record_fail_09b;

{$mode unleashed}

// anonymous record value expression is not allowed as a Type() operand
// (no expression syntax produces an anonymous record value at all in Pascal,
// so the parser hits a normal "illegal expression" path)
var
  y: Type(record a: Integer; end);
begin
end.
