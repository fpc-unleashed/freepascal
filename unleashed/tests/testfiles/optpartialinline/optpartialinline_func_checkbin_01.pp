{ %OPT="-O4 -OoPARTIALINLINE" %CHECKBIN_LACKS=FUNCCOLDZZZ }
{ Function variant of optpartialinline_checkbin_01. Foo is a FUNCTION: it is
  split into a tiny inlinable header (guard "x <= 0" -> exit(-1), then a call
  forwarding the parameter into $result) and an out-of-line body carrying the
  whole original code. At the single call site Foo(0) the header is inlined,
  the guard folds true, the body is never referenced, and smart-linking drops
  it together with the cold-only string constant FUNCCOLDZZZ. The companion
  optpartialinline_func_checkbin_off_01 compiles the same source with the pass
  off and asserts FUNCCOLDZZZ survives. }
program optpartialinline_func_checkbin_01;
{$mode objfpc}

function Foo(x: longint): longint;
begin
  if x <= 0 then
    exit(-1);
  writeln('FUNCCOLDZZZ', x);
  Result := x;
end;

begin
  if Foo(0) <> -1 then
    Halt(1);
end.
