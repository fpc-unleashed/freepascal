{ %OPT="-O4" }
{ Cross-jumping across managed (ansistring) tails inside a try/finally.  Two
  arms share an identical string-building tail (concat calls + Exit) that the
  merge collapses; a third arm raises, and the fall-through arm repeats the
  same tail.  Exercising every path must produce identical strings, run the
  finally block each time, and unwind the raise correctly -- the merge must
  not disturb reference counting or the exception frame. }
program optcrossjump_exceptions_01;
{$mode objfpc}{$H+}

uses
  SysUtils;

var
  finallyRuns: longint;

function build(x: longint): string; noinline;
var
  s: string;
begin
  s := '';
  try
    if x = 1 then begin s := s + 'A'; s := s + IntToStr(x * 3); s := s + 'Z'; Exit(s); end;
    if x = 2 then begin s := s + 'A'; s := s + IntToStr(x * 3); s := s + 'Z'; Exit(s); end;
    if x = 3 then raise Exception.Create('boom');
    s := s + 'A'; s := s + IntToStr(x * 3); s := s + 'Z';
    Result := s;
  finally
    Inc(finallyRuns);
  end;
end;

function expected(x: longint): string;
begin
  Result := 'A' + IntToStr(x * 3) + 'Z';
end;

var
  raised: boolean;
begin
  finallyRuns := 0;

  if build(1) <> expected(1) then Halt(1);
  if build(2) <> expected(2) then Halt(2);
  if build(4) <> expected(4) then Halt(3);

  raised := False;
  try
    build(3);
  except
    on E: Exception do
      raised := (E.Message = 'boom');
  end;
  if not raised then Halt(4);

  { four calls, each must have executed the finally exactly once }
  if finallyRuns <> 4 then Halt(5);

  Writeln('OK');
end.
