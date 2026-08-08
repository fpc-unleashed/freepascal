program inline_vars_in_on_do_try_01;
// inline var in a try body nested under an on..do handler

{$mode unleashed}

uses sysutils;

var
  hit: integer;

begin
  hit := 0;
  try
    raise exception.create('boom');
  except
    on e: exception do try
      var b := length(e.message);
      hit := b;
    except
      halt(1);
    end;
  end;
  if hit <> 4 then halt(2);
end.
