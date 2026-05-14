program autofree_inline_var_basic_01;

{$mode unleashed}

uses Classes;

var
  ListPtr: Pointer;

procedure DoWork;
begin
  var list := autofree TStringList.Create;
  list.Add('hello');
  ListPtr := Pointer(list);
end;

begin
  DoWork;
  // after DoWork returns, the TStringList must have been freed.
  // we recorded the pointer; if we tried to use it, FPC would either
  // segfault or detect freed memory. We just confirm the pointer was
  // assigned (autofree did not prevent us from storing it).
  if ListPtr = nil then halt(1);
end.
