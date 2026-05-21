{ %FAIL %NORUN }
program case_expr_unknown_pattern_id_01;
{$mode unleashed}

// same regression as case_unknown_pattern_id_01 but in expression form;
// the case-as-expression branch pattern must not silently lazy-label
function ArchName(a: Word): String;
begin
  result := case a of
    PROCESSOR_ARCHITECTURE_AMD64: 'x64';
  else
    'other';
  end;
end;

begin
end.
