{ %NORUN }
program backtick_lineending_source_01;

{$mode unleashed}
{$MULTILINESTRINGLINEENDING SOURCE}

const
  TWO =
`a
b`;

begin
  // SOURCE keeps whatever the source file uses (we don't assert specific
  // bytes here because the editor may rewrite line endings; just verify
  // it compiles)
  if Length(TWO) < 3 then halt(1);
end.
