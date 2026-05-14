program tuple_returned_via_array_param_01;

{$mode unleashed}

function CountAndSum(arr: array of Integer): (count, sum: Integer);
begin
  Result.count := Length(arr);
  Result.sum := 0;
  for var x in arr do
    Result.sum := Result.sum + x;
end;

begin
  var (n, s) := CountAndSum([10, 20, 30, 40]);
  if n <> 4   then halt(1);
  if s <> 100 then halt(2);

  var (n2, s2) := CountAndSum([5]);
  if n2 <> 1 then halt(3);
  if s2 <> 5 then halt(4);
end.
