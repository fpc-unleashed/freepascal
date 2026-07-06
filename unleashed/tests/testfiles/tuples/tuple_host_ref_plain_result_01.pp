program tuple_host_ref_plain_result_01;

{$mode unleashed}

// full-record store into a host-typed tuple field must not clobber the
// following field (the field slot was sized from the incomplete host)

type
  THost = record
    arr: array of LongWord;
    neg: boolean;
    function one: (p: THost; e: LongWord);
  end;

function THost.one: (p: THost; e: LongWord);
begin
  result.e := 42;
  result.p := self;
end;

var
  h: THost;

begin
  SetLength(h.arr, 1);
  h.arr[0] := 100;
  h.neg := true;
  var r := h.one;
  if PtrUInt(@r.e) - PtrUInt(@r.p) < SizeOf(THost) then halt(1);
  if r.e <> 42 then halt(2);
  if r.p.arr[0] <> 100 then halt(3);
  if not r.p.neg then halt(4);
end.
