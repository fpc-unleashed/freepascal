{ %FAIL }
program int128_fail_int128_from_variant_01;

{ a variant cannot deliver a 128 bit value, reading one into an Int128
  must not compile }

{$mode unleashed}

uses
  Variants;

var
  v: variant;
  a: Int128;

begin
  v := 42;
  a := v;
  writeln(a);
end.
