{ %FAIL %NORUN }
program match_underscore_first_in_comma_list_01;
{$mode unleashed}

// `_` is only legal as the LAST element of a comma list; at the start
// is rejected
var s: string;
begin
  s := match s of
    'a': 'A';
    _, 'b', 'c': 'else';
  end;
end.
