program multi_var_init_string_01;

{$mode unleashed}

var
  prefix, suffix, sep: String = '-';

begin
  if prefix <> '-' then halt(1);
  if suffix <> '-' then halt(2);
  if sep    <> '-' then halt(3);
  prefix := 'pre';
  if suffix <> '-' then halt(4);   // independent copy
end.
