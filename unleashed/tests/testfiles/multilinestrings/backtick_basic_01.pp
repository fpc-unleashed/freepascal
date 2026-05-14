program backtick_basic_01;

{$mode unleashed}

const
  empty   = ``;
  inline_ = `single line works too`;

begin
  if Length(empty) <> 0 then halt(1);
  if inline_ <> 'single line works too' then halt(2);
end.
