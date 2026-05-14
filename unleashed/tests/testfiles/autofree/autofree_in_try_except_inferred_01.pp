program autofree_in_try_except_inferred_01;

{$mode unleashed}

uses Classes;

// historic regression: autofree on an inferred inline-var assigned inside
// a try-except block must defer cleanup to the end of the enclosing scope,
// not fire when the try-body ends. Earlier versions fired too early and
// the variable became nil immediately after the try.

begin
  var list: TStringList;
  try
    list := autofree TStringList.Create;
  except
    halt(99);
  end;
  // list must still be a live instance here
  if list = nil then halt(1);
  list.Add('still alive');
  if list.Count <> 1 then halt(2);
end.
