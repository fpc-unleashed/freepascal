{ an implicit generic specialization used as an operand of a binary
  operator must resolve correctly on either side. previously only a
  bare leftmost specialization worked; as an operator operand it was
  left as an unresolved node and crashed code generation }
program implicit_generics_spec_in_expression_01;
{$mode unleashed}

type
  TBox<T>=class
    function Sum<U>(const val: U; n: Integer): Integer;
  end;

function Sz<U>(n: Integer): Integer;
begin
  Result := SizeOf(U) * n;
end;

function TBox<T>.Sum<U>(const val: U; n: Integer): Integer;
begin
  if n <= 0 then
    Result := 0
  else
    Result := SizeOf(U) + Sum<U>(val, n - 1);   // recursive call as right operand
end;

var
  b: TBox<Integer>;
begin
  { right-hand operand }
  if 10 + Sz<Word>(2) <> 14 then Halt(1);
  { left-hand operand }
  if Sz<Word>(2) + 10 <> 14 then Halt(2);
  { both operands are specializations }
  if Sz<Word>(2) + Sz<Byte>(3) <> 7 then Halt(3);
  { mixed with other operators }
  if 2 * Sz<Word>(1) + (8 div Sz<LongWord>(1)) <> 6 then Halt(4);
  { recursive specialization in an expression (the original crash) }
  b := TBox<Integer>.Create;
  if b.Sum<Word>(0, 3) <> 6 then Halt(5);
  b.Free;
end.
