program composable_records_string_field_01;

{$mode unleashed}

type
  TName = record
    first: AnsiString;
    last: AnsiString;
  end;
  TPerson = record
    embed TName;
    age: Integer;
  end;

var
  p, q: TPerson;
begin
  p.first := 'Jan';
  p.last := 'Kowalski';
  p.age := 42;
  if p.first <> 'Jan' then halt(1);
  if p.last <> 'Kowalski' then halt(2);
  { record copy: managed strings reference-count correctly }
  q := p;
  if q.first <> 'Jan' then halt(3);
  if q.last <> 'Kowalski' then halt(4);
  if q.age <> 42 then halt(5);
  { mutate q, p stays the same (copy-on-write) }
  q.first := 'Anna';
  if p.first <> 'Jan' then halt(6);
  if q.first <> 'Anna' then halt(7);
end.
