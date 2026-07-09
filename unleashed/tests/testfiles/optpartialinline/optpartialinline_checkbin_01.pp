{ %OPT="-O4 -OoPARTIALINLINE" %CHECKBIN_LACKS=COLDMARKERZZZ }
{ -OoPARTIALINLINE splits Foo into a tiny inlinable header (the guard + a call
  forwarding the parameter) and an out-of-line body that keeps the whole
  original code. At the single call site Foo(0) the header is inlined and its
  guard "0 <= 0" folds to true, so the body is never called; smart-linking then
  drops the now-unreferenced body, and with it the cold-only string constant
  COLDMARKERZZZ. The companion optpartialinline_disabled_01 compiles the very
  same source with the pass off and asserts COLDMARKERZZZ is still present. }
program optpartialinline_checkbin_01;
{$mode objfpc}

procedure Foo(x: longint);
begin
  if x <= 0 then
    exit;
  writeln('COLDMARKERZZZ', x);
end;

begin
  Foo(0);
end.
