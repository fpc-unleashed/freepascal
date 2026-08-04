program labels_with_try_in_branch_01;

{$mode unleashed}

uses SysUtils;

var
  trace: String = '';

procedure Run(target: Integer);
label
  state[0..2];
begin
  goto state[target];

  state[0]:
    begin
      try
        raise Exception.Create('s0');
      except
        on E: Exception do
          trace := trace + 's0:' + E.Message + ';';
      end;
      Exit;
    end;
  state[1]:
    begin
      trace := trace + 's1;';
      Exit;
    end;
  state[2]:
    begin
      trace := trace + 's2;';
      Exit;
    end;
end;

begin
  Run(0);
  Run(2);
  Run(1);
  if trace <> 's0:s0;s2;s1;' then halt(1);
end.
