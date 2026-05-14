program with_form_c_no_autofree_01;

{$mode unleashed}

uses Classes;

begin
  // Form C without autofree: caller is responsible for cleanup, defer covers it
  with var lst := TStringList.Create do
  begin
    defer lst.Free;
    lst.Add('hi');
    if lst.Count <> 1 then halt(1);
  end;
end.
