{ ThreadID returns a nonzero id, distinct per worker while both live }
program asyncawait_control_threadid_21;
{$mode unleashed}
uses SysUtils;
var gate: boolean;
procedure work;
begin
  while not gate do Sleep(1);
end;
begin
  gate := false;
  var a := async work;
  var b := async work;
  if PtrUInt(a.ThreadID) = 0 then halt(1);
  if PtrUInt(b.ThreadID) = 0 then halt(2);
  if a.ThreadID = b.ThreadID then halt(3);
  gate := true;
  await a;
  await b;
end.
