program int128_native_shifts_convert_01;

{ shift matrix with constant and variable counts, plus register-pair
  widening and narrowing conversions }

{$mode unleashed}

var
  v, r: UInt128;
  n: longint;
  a: Int128;
  i64: int64;
  q: qword;
  bt: byte;

begin
  v := 1267650600228229401634142158849;             { 2^100 + 2^37 + 1 }

  { constant counts }
  if v shl 0 <> v then halt(1);
  if v shl 1 <> 2535301200456458803268284317698 then halt(2);
  if v shr 1 <> 633825300114114700817071079424 then halt(3);
  if v shl 63 <> 1267650600237452773533557981184 then halt(4);
  if v shr 63 <> 137438953472 then halt(5);
  if v shl 64 <> 2535301200474905547067115962368 then halt(6);
  if v shr 64 <> 68719476736 then halt(7);
  if v shl 65 <> 5070602400949811094134231924736 then halt(8);
  if v shr 100 <> 1 then halt(9);
  if v shl 127 <> 170141183460469231731687303715884105728 then halt(10);
  if v shr 127 <> 0 then halt(11);

  { the same counts from a variable }
  n := 1;
  if v shl n <> 2535301200456458803268284317698 then halt(12);
  if v shr n <> 633825300114114700817071079424 then halt(13);
  n := 64;
  if v shl n <> 2535301200474905547067115962368 then halt(14);
  if v shr n <> 68719476736 then halt(15);
  n := 65;
  if v shl n <> 5070602400949811094134231924736 then halt(16);
  n := 127;
  if v shl n <> 170141183460469231731687303715884105728 then halt(17);
  if v shr n <> 0 then halt(18);

  { widening keeps the sign in the high half }
  i64 := -5;
  a := i64;
  if a <> -5 then halt(19);
  if a >= 0 then halt(20);
  q := 18446744073709551615;
  r := q;
  if r <> 18446744073709551615 then halt(21);

  { narrowing takes the low half }
  a := 300000000000;
  i64 := int64(a);
  if i64 <> 300000000000 then halt(22);
  bt := byte(a and 255);
  if bt <> 0 then halt(23);
  a := 511;
  bt := byte(a);
  if bt <> 255 then halt(24);

  { relabeling between the signednesses keeps the payload }
  a := -1;
  r := UInt128(a);
  if r <> high(UInt128) then halt(25);
  if Int128(r) <> -1 then halt(26);
end.
