{ %OPT="-O2 -OoREFELIDE" }
{ -OoREFELIDE across an exception raise/except path.  A borrowed local owns no
  reference, so it must NOT be finalized on the exception unwind (finalizing it
  would drop a refcount it never took -> double-free); the SOURCE is still
  finalized. The borrowed value is read inside the except handler, where the
  source (value parameter) is still alive. Heavy iteration makes any refcount
  corruption surface as wrong contents or a crash (nonzero exit). }
program optrefelide_exception_01;
{$mode objfpc}{$H+}
uses sysutils;

function BorrowThenRaise(v: ansistring; doraise: boolean): ansistring; noinline;
var tmp: ansistring;
begin
  BorrowThenRaise := '';
  try
    tmp := v;                 { borrow }
    if doraise then
      raise Exception.Create('boom');
    BorrowThenRaise := tmp;
  except
    on E: Exception do
      BorrowThenRaise := 'c:' + tmp;   { tmp still valid: source v alive }
  end;
end;

var
  i: integer;
  s: ansistring;
begin
  for i := 1 to 20000 do
  begin
    s := BorrowThenRaise('p' + IntToStr(i), true);
    if s <> 'c:p' + IntToStr(i) then Halt(1);
    s := BorrowThenRaise('q' + IntToStr(i), false);
    if s <> 'q' + IntToStr(i) then Halt(2);
  end;
end.
