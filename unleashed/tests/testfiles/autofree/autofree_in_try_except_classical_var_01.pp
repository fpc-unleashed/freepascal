program autofree_in_try_except_classical_var_01;

{$mode unleashed}

uses Classes;

// regression: classical var (declared in `var` section) with autofree
// assigned inside try-except. Cleanup must defer to the end of the
// enclosing scope, NOT fire when try-body ends.

var
  list: TStringList;

begin
  try
    list := autofree TStringList.Create;
  except
    halt(99);
  end;
  if list = nil then halt(1);
  list.Add('still alive');
  if list.Count <> 1 then halt(2);
end.
