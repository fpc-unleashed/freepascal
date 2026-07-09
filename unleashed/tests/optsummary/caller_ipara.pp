program caller_ipara;

{ Cross-unit consumer of iparalib.ADDONE. HOT keeps several values live across a
  call to the leaf ADDONE. Under the full ABI mask those values must be
  evacuated into callee-saved registers (push/pop %rbx/%r12/...); when
  iparalib's ppu carries ADDONE's proven (small) -OoIPARA clobber mask, the
  caller keeps them in untouched volatile registers and the callee-saved pushes
  disappear. The runtime result is identical either way. }

{$mode objfpc}

uses
  iparalib;

function hot(a, b, c, d: longint): longint; noinline;
var
  s: longint;
begin
  s := a * 2;
  s := s + addone(b);
  s := s + a;
  s := s + c;
  s := s + d;
  hot := s;
end;

begin
  { hot(10,20,30,40) = 20 + 21 + 10 + 30 + 40 = 121 }
  if hot(10, 20, 30, 40) <> 121 then
    Halt(1);
  writeln('ALL OK');
end.
