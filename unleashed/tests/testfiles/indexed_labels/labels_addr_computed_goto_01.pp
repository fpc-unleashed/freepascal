program labels_addr_computed_goto_01;

{$mode unleashed}
{$goto on}

var
  resultV: integer = 0;

procedure dispatch(i: byte);
label
  op[0..3];
var
  base, target: pointer;
  delta: array[0..3] of PtrUInt;
  k: byte;
begin
  base := @op[0];
  for k := 0 to 3 do
    delta[k] := PtrUInt(@op[k])-PtrUInt(base);
  target := pointer(PtrUInt(base)+delta[i]);
  goto target;

  op[0]: resultV := 100; exit;
  op[1]: resultV := 101; exit;
  op[2]: resultV := 102; exit;
  op[3]: resultV := 103; exit;
end;

var
  i: byte;
begin
  for i := 0 to 3 do begin
    dispatch(i);
    if resultV <> 100+i then halt(1+i);
  end;
end.
