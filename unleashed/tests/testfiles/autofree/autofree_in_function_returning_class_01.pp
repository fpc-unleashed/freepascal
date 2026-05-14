program autofree_in_function_returning_class_01;

{$mode unleashed}

uses Classes;

// returning the autofree-bound instance: caller takes ownership.
// Strictly speaking this is a smell since autofree implies "free at scope
// end", but FPC just emits Free at scope end on the variable - if the
// caller's variable is overwritten by the returned instance, the autofree
// at proc end works on a now-stale handle (nil, since we set it nil
// before exiting). The pattern below demonstrates the safer idiom: do NOT
// mark a returned instance with autofree.
function MakeOwned: TStringList;
begin
  Result := TStringList.Create;
  Result.Add('owned');
end;

begin
  var lst := autofree MakeOwned;
  if lst.Count <> 1 then halt(1);
  if lst[0] <> 'owned' then halt(2);
end.
