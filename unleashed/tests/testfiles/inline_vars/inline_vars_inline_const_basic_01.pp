program inline_vars_inline_const_basic_01;

{$mode unleashed}

// inline const in statement blocks: plain `const K = expr` gives a true
// compile-time constant, `const K: T = v` a block-scoped typed constant
procedure check_in_proc;
begin
  const P = 30;
  if P <> 30 then halt(1);
end;

var i, sum: integer;
begin
  const K = 50;
  if K <> 50 then halt(2);

  const S = 'hello';
  if S <> 'hello' then halt(3);

  const T: Integer = 7;
  if T <> 7 then halt(4);

  const A: array[3] of integer = (1, 2, 3);
  sum := 0;
  for i := 0 to 2 do sum := sum + A[i];
  if sum <> 6 then halt(5);

  begin
    const Inner = K * 2;
    if Inner <> 100 then halt(6);
  end;

  check_in_proc;

  if K + T <> 57 then halt(7);
end.
