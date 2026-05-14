program with_form_c_inferred_01;

{$mode unleashed}

uses Classes;

begin
  // Form C: inline-var with inferred type, with autofree
  with var lst := autofree TStringList.Create do
  begin
    lst.Add('one');
    lst.Add('two');
    if lst.Count <> 2 then halt(1);
  end;
end.
