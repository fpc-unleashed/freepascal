program if_expr_in_concat_01;

{$mode unleashed}

begin
  for var verbose := false to true do
  begin
    var prefix := 'msg' + (if verbose then ' [verbose]' else '');
    if (not verbose) and (prefix <> 'msg') then halt(1);
    if verbose       and (prefix <> 'msg [verbose]') then halt(2);
  end;
end.
