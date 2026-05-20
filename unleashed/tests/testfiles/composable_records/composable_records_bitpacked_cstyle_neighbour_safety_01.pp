program composable_records_bitpacked_cstyle_neighbour_safety_01;

{$mode unleashed}

type
  TBits = bitpacked record of Byte
    a: 2;
    b: 3;
    c: 3;
  end;

var
  r: TBits;
begin
  r.a := 1;
  r.b := 5;
  r.c := 7;
  { every neighbour write must keep prior fields intact }
  if r.a <> 1 then halt(1);
  r.b := 2;
  if r.a <> 1 then halt(2);
  if r.b <> 2 then halt(3);
  r.c := 6;
  if r.a <> 1 then halt(4);
  if r.b <> 2 then halt(5);
  if r.c <> 6 then halt(6);
end.
