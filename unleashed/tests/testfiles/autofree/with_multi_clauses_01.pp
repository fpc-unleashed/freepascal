program with_multi_clauses_01;

{$mode unleashed}

uses Classes;

begin
  // multiple clauses in one with, with mixed forms
  with var a := autofree TStringList.Create,
       var b := autofree TStringList.Create do
  begin
    a.Add('a-content');
    b.Add('b-content');
    if a.Count <> 1 then halt(1);
    if b.Count <> 1 then halt(2);
  end;
end.
