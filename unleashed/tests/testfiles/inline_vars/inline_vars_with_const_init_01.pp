program inline_vars_with_const_init_01;

{$mode unleashed}

const
  BASE = 100;
  NAME = 'fpc';

begin
  var n := BASE + 1;
  if n <> 101 then halt(1);

  var s := NAME + '-unleashed';
  if s <> 'fpc-unleashed' then halt(2);
end.
