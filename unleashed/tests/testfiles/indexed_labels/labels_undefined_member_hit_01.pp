{ %OPT=-O2 }
program labels_undefined_member_hit_01;

{$mode unleashed}

{ a family may declare more members than it defines; the dispatch must
  still reach the defined ones }

var
  resultV: integer = 0;

procedure run(n: integer);
label
  st[0..3];  // st[1] and st[3] stay undefined
begin
  goto st[n];
  resultV := -1;
  exit;

  st[0]: resultV := 1; exit;
  st[2]: resultV := 4; exit;
end;

begin
  run(0);
  if resultV <> 1 then halt(1);
  run(2);
  if resultV <> 4 then halt(2);
end.
