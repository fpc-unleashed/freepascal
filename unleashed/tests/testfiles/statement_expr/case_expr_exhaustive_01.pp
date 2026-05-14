program case_expr_exhaustive_01;

{$mode unleashed}

begin
  var b := true;
  var s := case b of
    true:  'yes';
    false: 'no';
  end;
  if s <> 'yes' then halt(1);

  b := false;
  s := case b of
    true:  'yes';
    false: 'no';
  end;
  if s <> 'no' then halt(2);
end.
