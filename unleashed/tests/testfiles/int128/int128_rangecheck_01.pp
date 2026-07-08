{ %OPT=-Cr }
program int128_rangecheck_01;

{ -Cr catches narrowing a 128 bit value that does not fit, and assigning a
  negative one to the unsigned type; in-range conversions do not raise }

{$mode unleashed}

uses
  sysutils;

var
  a: Int128;
  i: Int64;
  u: UInt128;

begin
  a := high(Int128);
  try
    i := a;
    halt(1);
  except
    on ERangeError do ;
  end;

  a := -5;
  try
    u := a;
    halt(2);
  except
    on ERangeError do ;
  end;

  a := 1234567890123456789;
  i := a;
  if i <> 1234567890123456789 then halt(3);
  i := high(Int64);
  a := i;
  if a <> high(Int64) then halt(4);
end.
