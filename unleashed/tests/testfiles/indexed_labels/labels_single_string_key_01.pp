program labels_single_string_key_01;

{$mode unleashed}

{ a one-element string key list stays valid - a string can never be read as
  a count, so the single-value rule does not apply }

label foo['only'];

begin
  goto foo['ONLY'];
  halt(1);
  foo['only']:
  halt(0);
end.
