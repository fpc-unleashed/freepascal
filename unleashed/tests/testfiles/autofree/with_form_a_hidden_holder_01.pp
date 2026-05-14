program with_form_a_hidden_holder_01;

{$mode unleashed}

uses Classes;

begin
  with autofree TStringList.Create do
  begin
    Add('a');
    Add('b');
    if Count <> 2 then halt(1);
  end;
end.
