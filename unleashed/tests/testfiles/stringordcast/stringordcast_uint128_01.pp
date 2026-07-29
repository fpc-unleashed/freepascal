program stringordcast_uint128_01;

{$mode unleashed}

type
  PUInt128 = ^UInt128;

const
  SIG_128 = UInt128('0123456789abcde'#$FF);

var
  buf: array[0..15] of AnsiChar = '0123456789abcde'#$FF;

begin
  // bytes 30 31 32 33 34 35 36 37 38 39 61 62 63 64 65 FF in source order;
  // little-endian UInt128 -> $FF656463626139383736353433323130
  if SIG_128 <> $FF656463626139383736353433323130 then halt(1);
  // reinterpreting a buffer through a pointer must match the folded constant
  if PUInt128(@buf[0])^ <> SIG_128 then halt(2);
end.
