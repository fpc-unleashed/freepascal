program case_expr_enum_01;

{$mode unleashed}

type
  TColor = (cRed, cGreen, cBlue);

begin
  for var c := cRed to cBlue do
  begin
    var name := case c of
      cRed:   'red';
      cGreen: 'green';
      cBlue:  'blue';
    end;
    case c of
      cRed:   if name <> 'red'   then halt(1);
      cGreen: if name <> 'green' then halt(2);
      cBlue:  if name <> 'blue'  then halt(3);
    end;
  end;
end.
