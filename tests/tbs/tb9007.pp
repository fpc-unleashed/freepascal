{ a value parameter written inside an inline routine must not change the
  caller's argument, also when the caller is itself expanded inline }
program tb9007;

{$mode objfpc}
{$inline on}

procedure setpara(n: longint); inline;
begin
  n := 1234;
  if n <> 1234 then Halt(2);
end;

procedure caller; inline;
var
  n: longint;
begin
  n := 1;
  setpara(n);
  if n <> 1 then Halt(1);
end;

begin
  caller;
end.
