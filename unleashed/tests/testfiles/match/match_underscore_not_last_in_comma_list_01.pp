{ %FAIL %NORUN }
program match_underscore_not_last_in_comma_list_01;
{$mode unleashed}

// `_` is only legal as the LAST element of a comma list; in the middle
// is rejected
var s: string;
begin
  s := match s of
    'a': 'A';
    'b', _, 'c': 'else';
  end;
end.
