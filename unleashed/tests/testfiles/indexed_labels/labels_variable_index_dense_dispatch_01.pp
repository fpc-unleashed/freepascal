{ %OPT=-O2 }
program labels_variable_index_dense_dispatch_01;

{$mode unleashed}

var
  resultV: integer = 0;

procedure run(n: integer);
label
  st[0..7];
begin
  goto st[n];

  st[0]: resultV := 1; exit;
  st[1]: resultV := 2; exit;
  st[2]: resultV := 4; exit;
  st[3]: resultV := 8; exit;
  st[4]: resultV := 16; exit;
  st[5]: resultV := 32; exit;
  st[6]: resultV := 64; exit;
  st[7]: resultV := 128; exit;
end;

var
  i, sum: integer;
begin
  sum := 0;
  for i := 0 to 7 do begin
    run(i);
    sum := sum+resultV;
  end;
  if sum <> 255 then halt(1);
  run(3);
  if resultV <> 8 then halt(2);
end.
