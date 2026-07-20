{ sync is a soft keyword decided by shape: before a statement-starting
  token it is the keyword, before `:=`, `;` or `(` it resolves to a user
  symbol, so both coexist in one scope. a method body sees Self }
program asyncawait_sync_soft_keyword_32;
{$mode unleashed}
uses SysUtils, Classes;
type
  TBox = class
    val: Integer;
    procedure bump;
  end;
procedure TBox.bump;
begin
  sync begin val := val + 5 end;
end;
var
  flag: Boolean;
procedure sync;
begin
  flag := true;
end;
procedure localvar;
begin
  var sync := 40;
  sync := sync + 2;          // assignment shape: the inline variable
  if sync <> 42 then halt(3);
end;
var
  b: TBox;
begin
  flag := false;
  sync;                      // call shape: the user procedure
  if not flag then halt(1);
  b := TBox.Create;
  b.val := 1;
  sync b.bump;               // statement shape: the keyword, same scope
  if b.val <> 6 then halt(2);
  b.Free;
  localvar;
end.
