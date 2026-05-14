program inline_vars_init_with_side_effect_01;

{$mode unleashed}

var
  call_count: Integer = 0;

function NextSeq: Integer;
begin
  Inc(call_count);
  Result := call_count;
end;

begin
  // initializer is evaluated exactly once
  var a := NextSeq;
  var b := NextSeq;
  var c := NextSeq;
  if a <> 1 then halt(1);
  if b <> 2 then halt(2);
  if c <> 3 then halt(3);
  if call_count <> 3 then halt(4);
end.
