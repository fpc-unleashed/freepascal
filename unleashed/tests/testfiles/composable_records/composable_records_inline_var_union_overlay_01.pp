program composable_records_inline_var_union_overlay_01;

{$mode unleashed}

procedure main;
begin
  var z: record
    a, b, c: Integer;
    union
      d: DWord;
      record
        z, q: Byte;
      end;
    end;
  end := (
    a: 1;
    b: 2;
    c: 3;
    d: $11223344;
  );

  if z.a <> 1 then halt(1);
  if z.b <> 2 then halt(2);
  if z.c <> 3 then halt(3);
  if z.d <> $11223344 then halt(4);
  { little-endian: low byte of $11223344 = $44 lands in z.z, next in z.q }
  if z.z <> $44 then halt(5);
  if z.q <> $33 then halt(6);
end;

begin
  main;
end.
