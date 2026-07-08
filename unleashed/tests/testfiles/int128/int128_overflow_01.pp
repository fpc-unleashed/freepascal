{ %OPT=-Co }
program int128_overflow_01;

{ -Co catches arithmetic that leaves the 128 bit range; operations that stay
  inside it do not raise }

{$mode unleashed}

uses
  sysutils;

var
  a, b: Int128;

begin
  a := high(Int128);
  b := 1;
  try
    a := a + b;
    halt(1);
  except
    on EIntOverflow do ;
  end;

  a := low(Int128);
  try
    a := a - 1;
    halt(2);
  except
    on EIntOverflow do ;
  end;

  a := high(Int128);
  try
    a := a * 2;
    halt(3);
  except
    on EIntOverflow do ;
  end;

  a := 1000000000000000000;
  b := 1000000000000000000;
  a := a * b;
  if a <> 1000000000000000000000000000000000000 then halt(4);
end.
