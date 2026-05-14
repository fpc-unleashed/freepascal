program with_form_b_existing_local_01;

{$mode unleashed}

uses Classes;

var
  list: TStringList;

begin
  with list := autofree TStringList.Create do
  begin
    list.Add('hello');
    if list.Count <> 1 then halt(1);
  end;
end.
