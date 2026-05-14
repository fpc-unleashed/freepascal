program case_expr_string_subject_via_match_01;

{$mode unleashed}

// case-of with strings is rejected, but match handles it as expression.
function Code(s: String): Integer;
begin
  Result := match s of
    'add': 1;
    'sub': 2;
    'mul': 3;
    'div': 4;
    _:     0;
  end;
end;

begin
  if Code('add') <> 1 then halt(1);
  if Code('sub') <> 2 then halt(2);
  if Code('mul') <> 3 then halt(3);
  if Code('div') <> 4 then halt(4);
  if Code('xyz') <> 0 then halt(5);
end.
