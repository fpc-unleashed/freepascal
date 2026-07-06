program tuple_host_ref_outer_record_01;

{$mode unleashed}

// tuple in a nested record's method references the OUTER record; the layout
// is only final once the outermost definition completes

type
  TOuter = record
    arr: array of LongWord;
    neg: boolean;
    type TInner = record
      val: byte;
      function look: array of (p: TOuter; e: LongWord);
    end;
  end;

function TOuter.TInner.look: array of (p: TOuter; e: LongWord);
begin
  SetLength(result, 1);
  SetLength(result[0].p.arr, 1);
  result[0].p.arr[0] := 1000 + val;
  result[0].p.neg := true;
  result[0].e := 46;
end;

var
  inner: TOuter.TInner;

begin
  inner.val := 7;
  var r := inner.look;
  if SizeOf(r[0]) < SizeOf(TOuter) + SizeOf(LongWord) then halt(1);
  if r[0].p.arr[0] <> 1007 then halt(2);
  if not r[0].p.neg then halt(3);
  if r[0].e <> 46 then halt(4);
end.
