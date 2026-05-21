{ %FAIL %NORUN }
program match_range_high_unknown_id_01;
{$mode unleashed}

// the high bound of a range pattern is also parsed by comp_expr; an
// undefined identifier there must report "Identifier not found"
function Bucket(n: Integer): String;
begin
  result := match n of
    0..UNKNOWN_LIMIT: 'low';
    _: 'high';
  end;
end;

begin
end.
