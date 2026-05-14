program raise_in_for_step_body_01;

{$mode unleashed}

uses SysUtils;

var
  visited: array of Integer = nil;

begin
  try
    for var i := 1 to 100 step 7 do
    begin
      visited := visited + [i];
      if i = 22 then
        raise Exception.Create('stop');
    end;
  except
    on E: Exception do
      if E.Message <> 'stop' then halt(99);
  end;
  // body ran at i = 1, 8, 15, 22 (raises right after appending 22)
  if Length(visited) <> 4  then halt(1);
  if visited[3]      <> 22 then halt(2);
end.
