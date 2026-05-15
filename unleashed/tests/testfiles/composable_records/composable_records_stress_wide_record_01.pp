program composable_records_stress_wide_record_01;

{$mode unleashed}

type
  TWide = record
    f01, f02, f03, f04, f05, f06, f07, f08: Integer;
    f09, f10, f11, f12, f13, f14, f15, f16: Integer;
    f17, f18, f19, f20, f21, f22, f23, f24: Integer;
    f25, f26, f27, f28, f29, f30, f31, f32: Integer;
  end;
  TWrapped = record
    embed TWide;
    tag: LongWord;
  end;

var
  w: TWrapped;
  i: Integer;
  sum: Integer;
  arr: array[1..32] of PInteger;
begin
  arr[1] := @w.f01; arr[2] := @w.f02; arr[3] := @w.f03; arr[4] := @w.f04;
  arr[5] := @w.f05; arr[6] := @w.f06; arr[7] := @w.f07; arr[8] := @w.f08;
  arr[9] := @w.f09; arr[10] := @w.f10; arr[11] := @w.f11; arr[12] := @w.f12;
  arr[13] := @w.f13; arr[14] := @w.f14; arr[15] := @w.f15; arr[16] := @w.f16;
  arr[17] := @w.f17; arr[18] := @w.f18; arr[19] := @w.f19; arr[20] := @w.f20;
  arr[21] := @w.f21; arr[22] := @w.f22; arr[23] := @w.f23; arr[24] := @w.f24;
  arr[25] := @w.f25; arr[26] := @w.f26; arr[27] := @w.f27; arr[28] := @w.f28;
  arr[29] := @w.f29; arr[30] := @w.f30; arr[31] := @w.f31; arr[32] := @w.f32;
  for i := 1 to 32 do
    arr[i]^ := i;
  sum := 0;
  for i := 1 to 32 do
    sum := sum + arr[i]^;
  if sum <> 32 * 33 div 2 then halt(1);
  w.tag := $deadbeef;
  if w.tag <> $deadbeef then halt(2);
end.
