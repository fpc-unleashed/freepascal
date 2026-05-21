{ %FAIL %NORUN }
program case_unknown_pattern_id_01;
{$mode unleashed}

// an undefined identifier used as a case pattern must report
// "identifier not found", not silently turn into a lazy label
function ArchName(a: Word): String;
begin
  case a of
    PROCESSOR_ARCHITECTURE_AMD64: result := 'x64';
  else
    result := 'other';
  end;
end;

begin
end.
