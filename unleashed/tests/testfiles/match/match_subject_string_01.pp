program match_subject_string_01;

{$mode unleashed}

function ToCmd(s: String): Integer;
begin
  match s of
    'start':  Result := 1;
    'stop':   Result := 2;
    'reset':  Result := 3;
    _:        Result := -1;
  end;
end;

begin
  if ToCmd('start') <> 1  then halt(1);
  if ToCmd('stop')  <> 2  then halt(2);
  if ToCmd('reset') <> 3  then halt(3);
  if ToCmd('foo')   <> -1 then halt(4);
end.
