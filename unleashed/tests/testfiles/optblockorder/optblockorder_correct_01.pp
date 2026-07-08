{ %OPT="-O4" }
{ Static-heuristic basic-block layout (-OoBLOCKORDER, on at -O4).  A batch of
  TResult/raise/assert-shaped routines whose error arms are cold regions the
  pass sinks out of the straight-line hot path.  Every hot path must still
  compute the right value and every moved error arm must still raise the right
  exception that the caller catches.  A layout bug corrupts a result or loses
  an exception and Halts with the check number. }
program optblockorder_correct_01;
{$mode objfpc}{$H+}
{$assertions on}

uses
  SysUtils;

var
  finallyRuns: longint;

{ guard-clause raise: cold arm calls fpc_raiseexception unconditionally }
function parseDigit(c: char): longint; noinline;
begin
  if (c < '0') or (c > '9') then
    raise EConvertError.Create('bad digit');
  Result := Ord(c) - Ord('0');
end;

{ loop whose body contains the guarded cold arm (loop-back edge is hot) }
function sumDigits(const s: string): longint; noinline;
var
  i: longint;
begin
  Result := 0;
  for i := 1 to Length(s) do
    Result := Result + parseDigit(s[i]);
end;

{ two independent cold error arms in one routine }
function checkedDiv(a, b: longint): longint; noinline;
begin
  if b = 0 then
    raise EDivByZero.Create('div0');
  if (a = low(longint)) and (b = -1) then
    raise ERangeError.Create('ovf');
  Result := a div b;
end;

{ assert failure: the helper may return, so the sunk arm keeps a rejoin jump }
procedure mustPositive(x: longint); noinline;
begin
  Assert(x > 0, 'not positive');
end;

{ nested try/finally over a managed type with a raising arm }
function withFinally(x: longint): string; noinline;
var
  s: string;
begin
  s := '';
  try
    try
      s := s + 'a';
      if x < 0 then
        raise Exception.Create('neg');
      s := s + IntToStr(x);
      Result := s;
    finally
      Inc(finallyRuns);
    end;
  except
    on E: Exception do
      Result := 'caught:' + E.Message;
  end;
end;

var
  caught: boolean;
begin
  { hot paths }
  if sumDigits('12345') <> 15 then Halt(1);
  if parseDigit('7') <> 7 then Halt(2);
  if checkedDiv(20, 4) <> 5 then Halt(3);
  mustPositive(9);                     { must not raise }

  { moved cold arms still raise and are caught }
  caught := False;
  try
    sumDigits('12x45');
  except
    on E: EConvertError do caught := True;
  end;
  if not caught then Halt(4);

  caught := False;
  try
    checkedDiv(10, 0);
  except
    on E: EDivByZero do caught := True;
  end;
  if not caught then Halt(5);

  caught := False;
  try
    mustPositive(-3);
  except
    on E: Exception do caught := True;   { EAssertionFailed }
  end;
  if not caught then Halt(6);

  { finally must run on both the normal and the raising path }
  finallyRuns := 0;
  if withFinally(8) <> 'a8' then Halt(7);
  if withFinally(-1) <> 'caught:neg' then Halt(8);
  if finallyRuns <> 2 then Halt(9);

  { a routine with no cold blocks is left correct }
  if checkedDiv(-10, 5) <> -2 then Halt(10);
end.
