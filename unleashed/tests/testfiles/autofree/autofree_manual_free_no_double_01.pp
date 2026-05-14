program autofree_manual_free_no_double_01;

{$mode unleashed}

uses Classes;

// the generated cleanup is `if x<>nil then begin x.Free; x:=nil end`
// so a manual Free + nil before scope end makes auto-cleanup a no-op.
procedure DoWork;
begin
  var list := autofree TStringList.Create;
  list.Add('x');
  list.Free;
  list := nil;
  // auto-cleanup at end of scope: nil check, no double free
end;

begin
  DoWork;
end.
