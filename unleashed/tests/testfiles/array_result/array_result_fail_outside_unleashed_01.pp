{ %FAIL }
{ outside unleashed mode the parser rejects an inline `array of X` as a
  function result type with "Type identifier expected" }
program array_result_fail_outside_unleashed_01;

{$mode objfpc}

function dynstr: array of string;
begin
  Result := ['aa', 'bb'];
end;

begin
end.
