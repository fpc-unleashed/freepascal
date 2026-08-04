{ scoped-with: `with var NAME : TYPE := EXPR do` ends the var's scope at the
  end of the with-body, so the same name can be reused in a sibling with }
program with_form_d_sibling_reuse_01;

{$mode unleashed}

uses
  sysutils;

type
  TPoint = record
    x, y: integer;
  end;

var
  log: string;

procedure run;
var
  src: TPoint;
begin
  with var p: TPoint := (x: 1; y: 2) do
    log := log + IntToStr(x) + ',' + IntToStr(y) + ';';

  src.x := 100;
  src.y := 200;
  with var p: TPoint := src do
    log := log + IntToStr(p.x) + ',' + IntToStr(p.y) + ';';

  with var q: record x, y: integer; end := (x: 5; y: 6) do
    log := log + IntToStr(x) + ',' + IntToStr(y) + ';';

  with var p: TPoint := (x: 7; y: 8) do
    log := log + IntToStr(p.x) + ',' + IntToStr(p.y) + ';';
end;

begin
  log := '';
  run;
  if log <> '1,2;100,200;5,6;7,8;' then
    begin
      WriteLn('FAIL: ', log);
      Halt(1);
    end;
end.
