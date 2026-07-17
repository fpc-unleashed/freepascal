{ %FAIL }
program int128_fail_variant_from_int128_01;

{ a variant has no 128 bit representation; the assignment used to pick
  a narrowing integer overload and truncate to the low byte }

{$mode unleashed}

uses
  Variants;

var
  v: variant;
  a: Int128;

begin
  a := 123456789012345678901234567890;
  v := a;
  writeln(VarToStr(v));
end.
