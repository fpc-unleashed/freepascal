program inline_var_inside_try_body_01;

{$mode unleashed}

uses SysUtils;

var
  caught_msg: String = '';

begin
  try
    var local_msg := 'inside-try';
    raise Exception.Create(local_msg);
  except
    on E: Exception do
      caught_msg := E.Message;
  end;
  if caught_msg <> 'inside-try' then halt(1);
end.
