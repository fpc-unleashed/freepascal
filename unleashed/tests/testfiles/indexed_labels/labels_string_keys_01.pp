program labels_string_keys_01;

{$mode unleashed}

label
  action['start', 'stop', 'reset'];

var
  hit: String = '';

begin
  goto action['stop'];

  action['start']: hit := 'started';  goto done;
  action['stop']:  hit := 'stopped';  goto done;
  action['reset']: hit := 'reset-ed';

done:
  if hit <> 'stopped' then halt(1);
end.
