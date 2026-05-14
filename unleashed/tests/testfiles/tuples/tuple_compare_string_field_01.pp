program tuple_compare_string_field_01;

{$mode unleashed}

begin
  if (1, 'apple') <>  (1, 'apple') then halt(1);
  if (1, 'apple')  =  (1, 'orange') then halt(2);
  if (1, 'apple') <  (1, 'orange') then else halt(3);
  if (1, 'orange') > (1, 'apple')  then else halt(4);
end.
