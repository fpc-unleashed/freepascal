program with_form_d_autofree_01;

{$mode unleashed}

uses Classes;

begin
  // Form D with autofree (explicit type variant of Form C)
  with var a: TStringList := autofree TStringList.Create do
  begin
    a.Add('x');
    if a.Count <> 1 then halt(1);
  end;
end.
