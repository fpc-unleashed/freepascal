program int128_hex_signext_01;

{ a hex literal fitting int64 is signed and sign-extends in a 128 bit slot, so
  $ffffffffffffffff is -1 (all bits), not 2^64-1; decimal gives the low mask }

{$mode unleashed}

var
  u: UInt128;

begin
  u := $ffffffffffffffff;
  if u <> high(UInt128) then halt(1);          { sign-extended -1 }
  u := 18446744073709551615;
  if u <> 18446744073709551615 then halt(2);   { decimal 2^64-1 }
  if u = high(UInt128) then halt(3);           { the two differ }
end.
