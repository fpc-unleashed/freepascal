{ %OPT=-O2 }
program labels_undefined_member_fallthrough_01;

{$mode unleashed}

{ an index selecting a declared but undefined member falls through to
  the statement after the goto }

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
  run(1);
  if resultV <> -1 then halt(1);
  run(3);
  if resultV <> -1 then halt(2);
  run(2);
  if resultV <> 4 then halt(3);
end.
