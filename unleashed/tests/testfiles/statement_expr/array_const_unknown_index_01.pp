{ %FAIL %NORUN }
program array_const_unknown_index_01;
{$mode unleashed}

// undefined identifier used as a positional index in an array constant
// initializer must report "identifier not found", not be silently auto
// registered as a label that swallows the `:`
const
  arr: array[0..2] of Integer = (
    UNKNOWN_IDX: 1,
    1: 2,
    2: 3
  );

begin
end.
