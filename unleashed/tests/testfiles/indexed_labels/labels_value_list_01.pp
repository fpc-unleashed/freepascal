program labels_value_list_01;

{$mode unleashed}

{ value lists with two or more elements stay valid: pure lists and
  range/value mixes; only the one-value spec is rejected }

label foo[256, 300];
label bar[0..2, 7];

begin
  goto foo[300];
  halt(1);
  foo[256]:
  halt(2);
  foo[300]:
  goto bar[7];
  halt(3);
  bar[0]:
  halt(4);
  bar[1]:
  halt(5);
  bar[2]:
  halt(6);
  bar[7]:
  halt(0);
end.
