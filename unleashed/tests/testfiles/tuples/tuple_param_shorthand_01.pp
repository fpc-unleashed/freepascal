program tuple_param_shorthand_01;

{$mode unleashed}

uses SysUtils;

procedure Show((x, y: Integer; name: String); var got: String);
begin
  got := name + '@' + IntToStr(x) + ',' + IntToStr(y);
end;

var
  s: String;

begin
  Show((1, 2, 'p'), s);
  if s <> 'p@1,2' then halt(1);
end.
