{ %OPT=-O2 }
program int128_rotate_idiom_01;

{ the rotate idiom (x shl n) or (x shr (bits-n)) must stay plain shifts
  for 128 bit values; the rol/ror rewrite has no 128 bit codegen }

{$mode unleashed}

var
  v: UInt128;
  n: longint;

begin
  v := 12345;
  n := 7;
  v := (v shl n) or (v shr (128 - n));
  if v <> 1580160 then halt(1);

  { constant counts }
  v := 1;
  v := (v shl 100) or (v shr 28);
  if v <> 1267650600228229401496703205376 then halt(2);

  { a rotation that actually wraps bits around }
  v := UInt128(1) shl 127;
  v := (v shl 1) or (v shr 127);
  if v <> 1 then halt(3);
end.
