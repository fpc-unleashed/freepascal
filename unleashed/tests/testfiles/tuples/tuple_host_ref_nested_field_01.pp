program tuple_host_ref_nested_field_01;

{$mode unleashed}

// host reference sits in a nested tuple; the inner tuple must get its final
// layout before the outer one computes field offsets around it

type
  THost = record
    arr: array of LongWord;
    neg: boolean;
    function look: (x: (y: THost; z: LongWord); w: LongWord);
  end;

function THost.look: (x: (y: THost; z: LongWord); w: LongWord);
begin
  result.x.z := 44;
  result.w := 45;
  result.x.y := self;
end;

var
  h: THost;

begin
  SetLength(h.arr, 1);
  h.arr[0] := 100;
  h.neg := true;
  var r := h.look;
  if PtrUInt(@r.x.z) - PtrUInt(@r.x.y) < SizeOf(THost) then halt(1);
  if r.x.y.arr[0] <> 100 then halt(2);
  if not r.x.y.neg then halt(3);
  if r.x.z <> 44 then halt(4);
  if r.w <> 45 then halt(5);
end.
