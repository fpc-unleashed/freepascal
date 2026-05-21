{ %FAIL %NORUN }
program match_comma_list_unknown_id_01;
{$mode unleashed}

// undefined identifier in the second position of a comma OR-list must
// report "Identifier not found" - regression for the lazy-label fix
function Tag(n: Integer): String;
begin
  result := match n of
    1, UNKNOWN_TWO, 3: 'a';
    _: 'b';
  end;
end;

begin
end.
