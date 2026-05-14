program autofree_existing_local_01;

{$mode unleashed}

uses Classes;

procedure DoWork;
var
  list: TStringList;
begin
  list := autofree TStringList.Create;
  list.Add('a');
  list.Add('b');
  if list.Count <> 2 then halt(1);
end;

begin
  DoWork;
end.
