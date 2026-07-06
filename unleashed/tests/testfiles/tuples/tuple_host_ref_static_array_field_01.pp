program tuple_host_ref_static_array_field_01;

{$mode unleashed}

// static array of the host inside a tuple field: the array size depends on
// the host size, so the slot must be sized from the completed host

type
  THost = record
    arr: array of LongWord;
    neg: boolean;
    function fixed: (p: array[3] of THost; e: LongWord);
  end;

function THost.fixed: (p: array[3] of THost; e: LongWord);
begin
  result.e := 43;
  for var i := 0 to 2 do begin
    SetLength(result.p[i].arr, 1);
    result.p[i].arr[0] := arr[0] + LongWord(i);
    result.p[i].neg := odd(i);
  end;
end;

var
  h: THost;

begin
  SetLength(h.arr, 1);
  h.arr[0] := 100;
  var r := h.fixed;
  if PtrUInt(@r.e) - PtrUInt(@r.p) < 3 * SizeOf(THost) then halt(1);
  if r.e <> 43 then halt(2);
  if r.p[0].arr[0] <> 100 then halt(3);
  if r.p[1].arr[0] <> 101 then halt(4);
  if r.p[2].arr[0] <> 102 then halt(5);
  if not r.p[1].neg then halt(6);
end.
