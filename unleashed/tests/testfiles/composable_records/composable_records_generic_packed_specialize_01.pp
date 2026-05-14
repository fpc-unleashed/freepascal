program composable_records_generic_packed_specialize_01;

{$mode unleashed}

type
  generic TVec3<T> = packed record
    x, y, z: T;
  end;

  TVec3I = specialize TVec3<LongInt>;
  TVec3B = specialize TVec3<Byte>;

var
  vi: TVec3I;
  vb: TVec3B;
begin
  vi.x := 100;
  vi.y := 200;
  vi.z := 300;
  vb.x := 1;
  vb.y := 2;
  vb.z := 3;
  if SizeOf(TVec3I) <> 12 then halt(1);
  if SizeOf(TVec3B) <>  3 then halt(2);
  if vi.x + vi.y + vi.z <> 600 then halt(3);
  if vb.x + vb.y + vb.z <> 6 then halt(4);
end.
