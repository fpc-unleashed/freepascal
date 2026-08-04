program labels_addr_variable_index_01;

{$mode unleashed}
{$goto on}

var
  resultV: integer = 0;

procedure run(i: integer);
label
  op[0..2];
var
  q: pointer;
begin
  q := @op[i];
  // an index with no member yields nil
  if q = nil then begin
    resultV := -1;
    exit;
  end;
  goto q;

  op[0]: resultV := 10; exit;
  op[1]: resultV := 20; exit;
  op[2]: resultV := 30; exit;
end;

begin
  run(0);
  if resultV <> 10 then halt(1);
  run(2);
  if resultV <> 30 then halt(2);
  run(7);
  if resultV <> -1 then halt(3);
end.
