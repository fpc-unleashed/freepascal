program tuple_host_ref_array_result_01;

{$mode unleashed}

// a tuple in a method signature references the host record while the host
// size is not final yet; the interface and implementation layouts must agree

type
  TBox = record
    arr: array of LongWord;
    neg: boolean;
    function pairs: array of (p: TBox; e: LongWord);
  end;

function TBox.pairs: array of (p: TBox; e: LongWord);
var
  res: array of (p: TBox; e: LongWord);
begin
  SetLength(res, 2);
  for var i := 0 to 1 do begin
    SetLength(res[i].p.arr, 1);
    res[i].p.arr[0] := arr[0] * LongWord(i + 1);
    res[i].p.neg := odd(i);
    res[i].e := LongWord(i + 7);
  end;
  result := res;
end;

var
  b: TBox;

begin
  SetLength(b.arr, 1);
  b.arr[0] := 500;
  var bp := b.pairs;
  if Length(bp) <> 2 then halt(1);
  if SizeOf(bp[0]) < SizeOf(TBox) + SizeOf(LongWord) then halt(2);
  if bp[0].p.arr[0] <> 500 then halt(3);
  if bp[0].e <> 7 then halt(4);
  if bp[0].p.neg then halt(5);
  if bp[1].p.arr[0] <> 1000 then halt(6);
  if bp[1].e <> 8 then halt(7);
  if not bp[1].p.neg then halt(8);
end.
