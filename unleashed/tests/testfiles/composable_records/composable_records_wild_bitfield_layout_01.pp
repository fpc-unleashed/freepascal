program composable_records_wild_bitfield_layout_01;

{$mode unleashed}

type
  { boolean 1-bit fields are reliable through bit-pack codegen }
  TFlags = bitpacked record of Boolean
    a, b, c, d, e, f, g, h: 1;
  end;

var
  f: TFlags;
begin
  f.a := True;
  f.c := True;
  f.f := True;
  f.h := True;
  if not f.a then halt(1);
  if     f.b then halt(2);
  if not f.c then halt(3);
  if not f.f then halt(4);
  if not f.h then halt(5);
  if SizeOf(TFlags) <> 1 then halt(6);
end.
