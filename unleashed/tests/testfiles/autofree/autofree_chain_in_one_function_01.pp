program autofree_chain_in_one_function_01;

{$mode unleashed}

uses Classes;

procedure DoWork;
begin
  // many autofree-bound objects, all freed at proc end
  var a := autofree TStringList.Create;
  var b := autofree TStringList.Create;
  var c := autofree TStringList.Create;
  var d := autofree TStringList.Create;
  var e := autofree TStringList.Create;
  a.Add('a');
  b.Add('b');
  c.Add('c');
  d.Add('d');
  e.Add('e');
  if a.Count + b.Count + c.Count + d.Count + e.Count <> 5 then halt(1);
end;

begin
  DoWork;
end.
