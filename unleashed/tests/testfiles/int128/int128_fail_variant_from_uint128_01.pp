{ %FAIL }
program int128_fail_variant_from_uint128_01;

{ a variant has no 128 bit representation, assigning an UInt128 must
  not compile }

{$mode unleashed}

uses
  Variants;

var
  v: variant;
  u: UInt128;

begin
  u := high(UInt128);
  v := u;
  writeln(VarToStr(v));
end.
