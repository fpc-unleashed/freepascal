{ %OPT="-O2 -OoSIBCALL" }
{ -OoSIBCALL must fall back to a plain call whenever a pointer into the routine's
  own frame can reach the callee, even if no NAMED local/parameter is
  address-taken. Compiler-generated temporaries -- an open array of const, or a
  @temp passed by reference -- escape the addr_taken symbol scan, so the pass
  additionally rejects any routine that materialises a frame address into a
  register. Tearing the frame down before the jump would leave the callee reading
  dangling stack. Behaviour must stay correct. }
program sibcall_frameaddr_negative_01;
{$mode objfpc}{$H+}
uses SysUtils;

{ open array of const built in this frame, address passed to Format (tail) }
function Describe(code: longint): string;
begin
  Describe := Format('[%d]', [code]);
end;

{ @temp: address of a local staged value passed by reference to the callee }
procedure AddInto(var acc: longint; const v: longint);
begin
  acc := acc + v;
end;

function Combine(a, b: longint): longint;
var
  t: longint;
begin
  t := a * 2;
  AddInto(t, b);   { @t -> frame address escapes to callee in tail position }
  Combine := t;
end;

begin
  if Describe(7) <> '[7]' then Halt(1);
  if Describe(42) <> '[42]' then Halt(2);
  if Combine(10, 3) <> 23 then Halt(3);   { 10*2 + 3 }
  if Combine(0, 5) <> 5 then Halt(4);
end.
