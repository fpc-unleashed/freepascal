{ %OPT="-O4 -OoNOPARTIALINLINE" %CHECKBIN_HAS=COLDMARKERZZZ }
{ Control for optpartialinline_checkbin_01: identical source, but with the
  pass explicitly disabled. Foo is not split, so the ordinary (non-inline)
  call Foo(0) keeps the whole body -- including the cold string constant
  COLDMARKERZZZ -- in the binary. }
program optpartialinline_disabled_01;
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
