program tuple_host_ref_object_result_01;

{$mode unleashed}

// same incomplete-host layout hazard for tp-style objects (inline storage
// like records, unlike classes)

type
  TObj = object
    arr: array of LongWord;
    neg: boolean;
    function pairs: array of (p: TObj; e: LongWord);
  end;

function TObj.pairs: array of (p: TObj; e: LongWord);
begin
  SetLength(result, 2);
  for var i := 0 to 1 do begin
    SetLength(result[i].p.arr, 1);
    result[i].p.arr[0] := arr[0] * LongWord(i + 1);
    result[i].p.neg := odd(i);
    result[i].e := LongWord(i + 7);
  end;
end;

var
  o: TObj;

begin
  SetLength(o.arr, 1);
  o.arr[0] := 500;
  var op := o.pairs;
  if SizeOf(op[0]) < SizeOf(TObj) + SizeOf(LongWord) then halt(1);
  if op[0].p.arr[0] <> 500 then halt(2);
  if op[0].e <> 7 then halt(3);
  if op[1].p.arr[0] <> 1000 then halt(4);
  if op[1].e <> 8 then halt(5);
  if not op[1].p.neg then halt(6);
end.
