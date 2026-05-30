program strinterp_types_class_tostring_01;

{$mode unleashed}

uses sysutils;

type
  TPoint = class(TObject)
    x, y: integer;
    function ToString: ansistring; override;
  end;

function TPoint.ToString: ansistring;
begin
  result := '(' + IntToStr(x) + ',' + IntToStr(y) + ')';
end;

var
  p: TPoint;
  s: string;
begin
  p := TPoint.Create;
  try
    p.x := 3;
    p.y := 4;
    s := $'p={p}';
    if s <> 'p=(3,4)' then halt(1);
  finally
    p.Free;
  end;
end.
