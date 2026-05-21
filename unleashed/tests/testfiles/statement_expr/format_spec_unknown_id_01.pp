{ %FAIL %NORUN }
program format_spec_unknown_id_01;
{$mode unleashed}

// an undefined identifier in WriteLn format spec (`IDENT:width`) is no
// longer eaten by the lazy-label path - it now reports "Identifier not
// found" instead of a misleading ")" / "ordinal const" syntax error
begin
  Write(UNKNOWN_VAR:5);
end.
