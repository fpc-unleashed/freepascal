{ %OPT=-O4 }
{ Multi-variable map: every arm assigns the SAME ordered pair of variables
  (weight:longint, weekend:boolean) to compile-time constants, so the case is
  converted to TWO parallel static lookup tables sharing one range guard.  The
  targets are out parameters (by-reference writable ordinals).  Checked over the
  whole enum plus, via a signed selector with negative labels, that a
  contiguous range starting below zero is handled correctly.  Halt(nonzero) =
  failure. }
program optswitchtable_multivar_01;
{$mode objfpc}{$H+}

type
  TDay = (dMon, dTue, dWed, dThu, dFri, dSat, dSun);

procedure info(d: TDay; out weight: longint; out weekend: boolean); noinline;
begin
  case d of
    dMon: begin weight := 1; weekend := false; end;
    dTue: begin weight := 2; weekend := false; end;
    dWed: begin weight := 3; weekend := false; end;
    dThu: begin weight := 4; weekend := false; end;
    dFri: begin weight := 5; weekend := false; end;
    dSat: begin weight := 6; weekend := true;  end;
    dSun: begin weight := 7; weekend := true;  end;
  end;
end;

{ signed selector with a contiguous range spanning negative labels }
function bucket(x: longint): longint; noinline;
var
  r: longint;
begin
  r := 999;
  case x of
    -2: r := 1;
    -1: r := 2;
     0: r := 3;
     1: r := 4;
     2: r := 5;
  else
    r := -1;
  end;
  bucket := r;
end;

var
  d: TDay;
  w: longint;
  we: boolean;
  x: longint;
begin
  for d := dMon to dSun do
    begin
      info(d, w, we);
      if w <> ord(d) + 1 then Halt(1);
      if we <> (d in [dSat, dSun]) then Halt(2);
    end;

  for x := -5 to 5 do
    begin
      if (x >= -2) and (x <= 2) then
        begin if bucket(x) <> x + 3 then Halt(3); end
      else
        if bucket(x) <> -1 then Halt(4);
    end;

  Halt(0);
end.
