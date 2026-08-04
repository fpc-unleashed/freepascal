{ inline var with anonymous pointer type whose target name starts with `T`
  used to fail because the scanner pre-fetched `^T...` as a control-character
  literal before the parser switched to bt_var_type }
program inline_vars_caret_type_after_colon_01;

{$mode unleashed}

type
  TOKEN_PRIVILEGES = record
    PrivilegeCount: longword;
  end;

procedure test;
begin
  var p: ^TOKEN_PRIVILEGES;
  p := nil;
  if p <> nil then
    Halt(1);
end;

begin
  test;
  WriteLn('OK');
end.
