program for_in_array_with_per_iter_try_01;

{$mode unleashed}

uses SysUtils;

begin
  var inputs: array of String := ['1', '2', 'bad', '4', 'oops', '6'];
  var sum := 0;
  var errors := 0;
  for var s in inputs do
  begin
    try
      sum := sum + StrToInt(s);
    except
      on E: EConvertError do
        Inc(errors);
    end;
  end;
  if sum    <> 13 then halt(1);
  if errors <> 2  then halt(2);
end.
