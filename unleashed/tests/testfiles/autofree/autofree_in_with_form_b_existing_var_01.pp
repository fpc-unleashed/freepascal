program autofree_in_with_form_b_existing_var_01;

{$mode unleashed}

uses Classes;

var
  list: TStringList;
  count_at_end: Integer;

begin
  with list := autofree TStringList.Create do
  begin
    list.Add('a');
    list.Add('b');
    list.Add('c');
    count_at_end := list.Count;
  end;
  if count_at_end <> 3 then halt(1);
end.
