program tuple_host_dynarray_field_01;

{$mode unleashed}

// a dynamic array of the host inside a tuple field is pointer-sized, so it
// is legal even though the host is not complete yet

type
  THost = record
    t: (p: array of THost; e: Integer);
  end;

var
  h: THost;

begin
  SetLength(h.t.p, 2);
  h.t.p[0].t.e := 10;
  h.t.p[1].t.e := 20;
  h.t.e := 5;
  if h.t.e <> 5 then halt(1);
  if h.t.p[0].t.e <> 10 then halt(2);
  if h.t.p[1].t.e <> 20 then halt(3);
  if Length(h.t.p[0].t.p) <> 0 then halt(4);
end.
