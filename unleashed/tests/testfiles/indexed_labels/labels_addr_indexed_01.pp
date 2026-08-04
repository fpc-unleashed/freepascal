program labels_addr_indexed_01;

{$mode unleashed}

var
  resultV: integer = 0;

procedure runNum;
label
  t[0..2];
var
  q: pointer;
begin
  q := @t[1];
  goto q;

  t[0]: resultV := 10; exit;
  t[1]: resultV := 20; exit;
  t[2]: resultV := 30; exit;
end;

procedure runStr;
label
  s['ADD', 'SUB'];
var
  q: pointer;
begin
  q := @s['SUB'];
  goto q;

  s['ADD']: resultV := 1; exit;
  s['SUB']: resultV := 2; exit;
end;

begin
  runNum;
  if resultV <> 20 then halt(1);
  runStr;
  if resultV <> 2 then halt(2);
end.
