program tuple_destructure_after_try_01;

{$mode unleashed}

uses SysUtils;

function Maybe(s: String): (ok: Boolean; v: Integer);
begin
  try
    Result := (ok: true, v: StrToInt(s));
  except
    Result := (ok: false, v: -1);
  end;
end;

begin
  var (good, value) := Maybe('42');
  if not good      then halt(1);
  if value <> 42   then halt(2);

  var (bad, value2) := Maybe('xyz');
  if bad           then halt(3);
  if value2 <> -1  then halt(4);
end.
