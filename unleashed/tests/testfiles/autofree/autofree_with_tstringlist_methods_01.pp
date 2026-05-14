program autofree_with_tstringlist_methods_01;

{$mode unleashed}

uses Classes;

begin
  var list := autofree TStringList.Create;
  list.Add('hello');
  list.Add('world');
  list.Add('unleashed');
  if list.Count <> 3 then halt(1);
  if list[0] <> 'hello' then halt(2);
  if list.IndexOf('world') <> 1 then halt(3);

  list.Sort;
  if list[0] <> 'hello'     then halt(4);
  if list[1] <> 'unleashed' then halt(5);
  if list[2] <> 'world'     then halt(6);
end.
