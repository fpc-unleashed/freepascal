{ %OPT=-O2 }
program labels_undefined_member_large_family_01;

{$mode unleashed}

{ label op[byte] declares 256 potential targets; only a handful are
  defined, the rest must neither warn nor crash and an index hitting
  them falls through }

var
  resultV: integer = 0;

procedure run(n: byte);
label
  op[byte];
begin
  goto op[n];
  resultV := -1;
  exit;

  op[0]: resultV := 1; exit;
  op[7]: resultV := 7; exit;
  op[250]: resultV := 250; exit;
end;

begin
  run(0);
  if resultV <> 1 then halt(1);
  run(7);
  if resultV <> 7 then halt(2);
  run(250);
  if resultV <> 250 then halt(3);
  run(5);
  if resultV <> -1 then halt(4);
  run(200);
  if resultV <> -1 then halt(5);
end.
