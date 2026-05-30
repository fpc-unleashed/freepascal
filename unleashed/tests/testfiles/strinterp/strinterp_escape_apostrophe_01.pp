program strinterp_escape_apostrophe_01;

{$mode unleashed}

var
  name: string;
  s: string;
begin
  name := 'Alice';
  s := $'it''s {name}';
  if s <> 'it''s Alice' then halt(1);

  s := $'''';
  if s <> '''' then halt(2);

  s := $'a''b''c';
  if s <> 'a''b''c' then halt(3);
end.
