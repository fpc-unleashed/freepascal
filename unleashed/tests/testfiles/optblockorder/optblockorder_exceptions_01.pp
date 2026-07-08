{ %OPT="-O4" }
{ Exception semantics after the raising block is relocated.  Several distinct
  exception classes are raised from cold guard arms that -OoBLOCKORDER sinks
  to the end of their routines; the matching handler must still fire for the
  right class and the message must survive.  Nested try/finally around the
  raise must run its cleanup exactly once even though the raise call was
  moved out of line. }
program optblockorder_exceptions_01;
{$mode objfpc}{$H+}

uses
  SysUtils;

type
  EAlpha = class(Exception);
  EBeta = class(Exception);

var
  cleanups: longint;

function pick(kind: longint): string; noinline;
begin
  Result := 'ok';
  cleanups := 0;
  try
    if kind = 1 then
      raise EAlpha.Create('alpha-msg');
    if kind = 2 then
      raise EBeta.Create('beta-msg');
    if kind = 3 then
      raise EConvertError.Create('conv-msg');
    { hot fall-through }
    Result := 'plain';
  finally
    Inc(cleanups);
  end;
end;

function trap(kind: longint; out msg: string): string; noinline;
begin
  msg := '';
  try
    Result := pick(kind);
  except
    on E: EAlpha do begin msg := E.Message; Result := 'A'; end;
    on E: EBeta do begin msg := E.Message; Result := 'B'; end;
    on E: EConvertError do begin msg := E.Message; Result := 'C'; end;
  end;
end;

var
  m: string;
begin
  if trap(0, m) <> 'plain' then Halt(1);
  if cleanups <> 1 then Halt(2);

  if trap(1, m) <> 'A' then Halt(3);
  if m <> 'alpha-msg' then Halt(4);
  if cleanups <> 1 then Halt(5);

  if trap(2, m) <> 'B' then Halt(6);
  if m <> 'beta-msg' then Halt(7);

  if trap(3, m) <> 'C' then Halt(8);
  if m <> 'conv-msg' then Halt(9);
  if cleanups <> 1 then Halt(10);
end.
