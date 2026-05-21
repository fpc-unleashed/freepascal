{ %FAIL %NORUN }
program match_unknown_pattern_id_01;
{$mode unleashed}

// an undefined identifier used as a match pattern must be reported as
// "identifier not found", not silently auto-registered as a lazy label
// (which would consume the `:` and produce a misleading syntax error)
function ArchName(a: Word): String;
begin
  result := match a of
    PROCESSOR_ARCHITECTURE_AMD64: 'x64';
    _:                            'unknown';
  end;
end;

begin
end.
