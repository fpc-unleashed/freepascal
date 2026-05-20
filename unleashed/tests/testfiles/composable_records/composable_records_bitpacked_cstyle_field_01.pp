program composable_records_bitpacked_cstyle_field_01;

{$mode unleashed}

type
  { Boolean-based bitpacked record is the supported path for
    individual-bit fields through C-style `name: N` shorthand. }
  TBits = bitpacked record of Boolean
    a, b, c: 1;
    d, e, f: 1;
    g, h: 1;
  end;

var
  r: TBits;
begin
  r.a := True;
  r.c := True;
  r.h := True;
  if not r.a then halt(1);
  if     r.b then halt(2);
  if not r.c then halt(3);
  if not r.h then halt(4);
  if SizeOf(TBits) <> 1 then halt(5);
end.
