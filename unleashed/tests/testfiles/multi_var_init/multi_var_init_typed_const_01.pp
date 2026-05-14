program multi_var_init_typed_const_01;

{$mode unleashed}

const
  MinX, MinY, MinZ: Integer = 0;
  Lo, Hi: Double = 3.5;

begin
  if MinX <> 0   then halt(1);
  if MinY <> 0   then halt(2);
  if MinZ <> 0   then halt(3);
  if Lo   <> 3.5 then halt(4);
  if Hi   <> 3.5 then halt(5);
end.
