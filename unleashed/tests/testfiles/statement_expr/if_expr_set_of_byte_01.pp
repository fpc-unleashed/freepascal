program if_expr_set_of_byte_01;

{$mode unleashed}

type
  TByteSet = set of byte;

var
  b: TByteSet;
  flag: boolean;
begin
  // non-enum ordinal set base
  flag := true;
  b := if flag then [1, 200] else [];
  if b <> [1, 200] then halt(1);
  b := b + (if flag then [42] else []);
  if b <> [1, 42, 200] then halt(2);
  flag := false;
  b := if flag then [1, 200] else [];
  if b <> [] then halt(3);
end.
