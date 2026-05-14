program composable_records_union_inside_packed_01;

{$mode unleashed}

type
  TRec = packed record
    hdr: Byte;
    union of Byte size 2
      n: Word;
      bb: array[0..1] of Byte;
    end;
    trail: Byte;
  end;

var
  r: TRec;
begin
  r.hdr := $AA;
  r.n := $BBCC;
  r.trail := $DD;
  if r.hdr <> $AA then halt(1);
  if r.bb[0] <> $CC then halt(2);
  if r.bb[1] <> $BB then halt(3);
  if r.trail <> $DD then halt(4);
  if SizeOf(TRec) <> 4 then halt(5);
end.
