program forstep_in_try_with_continue_after_catch_01;

{$mode unleashed}

uses SysUtils;

var
  visited: array of Integer = nil;

begin
  for var i := 1 to 20 step 3 do
  begin
    try
      if i = 7 then
        raise Exception.Create('skip');
      visited := visited + [i];
    except
      on E: Exception do
        ;   // swallow, loop continues
    end;
  end;
  // body would visit 1, 4, 7, 10, 13, 16, 19; we skip i=7
  if Length(visited) <> 6 then halt(1);
  if visited[0] <> 1  then halt(2);
  if visited[1] <> 4  then halt(3);
  if visited[2] <> 10 then halt(4);
  if visited[5] <> 19 then halt(5);
end.
