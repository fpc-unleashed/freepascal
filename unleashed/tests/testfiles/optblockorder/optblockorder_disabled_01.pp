{ %OPT="-O4 -OoNOBLOCKORDER" }
{ The correct_01 logic compiled with block-layout reordering DISABLED.  The
  observable behaviour must be byte-for-byte identical to the enabled build:
  same results, same exceptions caught, same finally count.  This is the
  control that proves the transform changes only placement, not semantics. }
program optblockorder_disabled_01;
{$mode objfpc}{$H+}
{$assertions on}

uses
  SysUtils;

var
  finallyRuns: longint;

function parseDigit(c: char): longint; noinline;
begin
  if (c < '0') or (c > '9') then
    raise EConvertError.Create('bad digit');
  Result := Ord(c) - Ord('0');
end;

function sumDigits(const s: string): longint; noinline;
var
  i: longint;
begin
  Result := 0;
  for i := 1 to Length(s) do
    Result := Result + parseDigit(s[i]);
end;

function checkedDiv(a, b: longint): longint; noinline;
begin
  if b = 0 then
    raise EDivByZero.Create('div0');
  if (a = low(longint)) and (b = -1) then
    raise ERangeError.Create('ovf');
  Result := a div b;
end;

procedure mustPositive(x: longint); noinline;
begin
  Assert(x > 0, 'not positive');
end;

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
  if sumDigits('12345') <> 15 then Halt(1);
  if parseDigit('7') <> 7 then Halt(2);
  if checkedDiv(20, 4) <> 5 then Halt(3);
  mustPositive(9);

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
    on E: Exception do caught := True;
  end;
  if not caught then Halt(6);

  finallyRuns := 0;
  if withFinally(8) <> 'a8' then Halt(7);
  if withFinally(-1) <> 'caught:neg' then Halt(8);
  if finallyRuns <> 2 then Halt(9);

  if checkedDiv(-10, 5) <> -2 then Halt(10);
end.
