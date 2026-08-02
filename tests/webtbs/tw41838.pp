program tw41838;

{$mode objfpc}
{$modeswitch advancedrecords}

type
  TPlain = record
    class var X: DWord;
  end;

  TVariant = record
    class var
      case byte of
        0: (X: DWord);
  end;

  TTagged = record
    class var
      case tag: byte of
        0: (a: DWord);
        1: (lo, hi: Word);
  end;

  TMixed = record
    f: LongInt;
    class var
      case byte of
        0: (s: DWord);
  end;

var
  p, q: TPlain;
  a, b: TVariant;
  m1, m2: TMixed;
  n: LongInt;
begin
  n:=SizeOf(TPlain);
  if n<>0 then
    halt(1);
  { a variant part holding only class vars must not add instance layout }
  n:=SizeOf(TVariant);
  if n<>0 then
    halt(2);
  if @p.X<>@q.X then
    halt(3);
  if @a.X<>@b.X then
    halt(4);
  { reachable through the type name }
  TVariant.X:=123;
  if (a.X<>123) or (b.X<>123) then
    halt(5);
  { variants overlay each other in the shared storage }
  TTagged.a:=$00010002;
  if (TTagged.lo<>2) or (TTagged.hi<>1) then
    halt(6);
  TTagged.tag:=7;
  if TTagged.tag<>7 then
    halt(7);
  { instance fields next to a class var variant part stay per instance }
  n:=SizeOf(TMixed);
  if n<>SizeOf(LongInt) then
    halt(8);
  m1.f:=1;
  m2.f:=2;
  TMixed.s:=77;
  if (m1.f<>1) or (m2.f<>2) or (m1.s<>77) or (m2.s<>77) then
    halt(9);
end.
