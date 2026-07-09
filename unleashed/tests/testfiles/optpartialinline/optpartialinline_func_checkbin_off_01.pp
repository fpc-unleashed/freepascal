{ %OPT="-O4 -OoNOPARTIALINLINE" %CHECKBIN_HAS=FUNCCOLDZZZ }
{ Control for optpartialinline_func_checkbin_01: identical source, pass off.
  The function Foo is not split, so the ordinary (non-inline) call Foo(0)
  retains the whole body -- including the cold string constant FUNCCOLDZZZ --
  in the binary. }
program optpartialinline_func_checkbin_off_01;
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
