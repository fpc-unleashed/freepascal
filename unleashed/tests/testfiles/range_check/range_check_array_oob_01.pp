{ %OPT=-Cr }
program range_check_array_oob_01;

{$mode unleashed}

uses SysUtils;

var
  arr: array[0..4] of Integer;

begin
  arr[0] := 1;
  // runtime out-of-bounds access must raise ERangeError under -Cr
  // (use a variable index so the compiler does not catch it at compile time)
  var idx := 10;
  try
    var v := arr[idx];
    halt(1);   // should not reach
  except
    on e: ERangeError do
      ; // expected
    on e: Exception do
      halt(2);
  end;
end.
